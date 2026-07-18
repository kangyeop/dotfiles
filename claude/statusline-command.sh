#!/bin/bash
# Claude Code status line script

input=$(cat)

# Colors (ANSI escape codes)
RESET="\033[0m"
CYAN="\033[38;5;73m"
GREEN="\033[38;5;114m"
YELLOW="\033[38;5;179m"
ORANGE="\033[38;5;209m"
DIM="\033[2m"
SEPARATOR="${DIM}|${RESET}"

# Context window usage
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Rate limits
five_h=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
seven_d=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
five_h_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
seven_d_reset=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

# Format seconds remaining into human-friendly string (e.g. 3h12m, 1d5h, 42m)
format_remaining() {
  local target="$1"
  [ -z "$target" ] && return
  local now
  now=$(date +%s)
  # target may be Unix epoch (int) or ISO-8601; normalize to epoch
  local epoch="$target"
  if ! [[ "$target" =~ ^[0-9]+$ ]]; then
    # Try GNU date first, then BSD date
    epoch=$(date -d "$target" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%S" "${target%%.*}" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%SZ" "${target%%.*}Z" +%s 2>/dev/null)
  fi
  [ -z "$epoch" ] && return
  local diff=$(( epoch - now ))
  [ "$diff" -le 0 ] && { printf "0m"; return; }
  local days=$(( diff / 86400 ))
  local hours=$(( (diff % 86400) / 3600 ))
  local mins=$(( (diff % 3600) / 60 ))
  if [ "$days" -gt 0 ]; then
    printf "%dd%dh" "$days" "$hours"
  elif [ "$hours" -gt 0 ]; then
    printf "%dh%dm" "$hours" "$mins"
  else
    printf "%dm" "$mins"
  fi
}

parts=()

# Current directory (from JSON cwd)
cwd=$(echo "$input" | jq -r '.cwd // empty')
if [ -n "$cwd" ]; then
  # Shorten home directory to ~
  short_cwd="${cwd/#$HOME/~}"
  parts+=("$(printf "${CYAN}%s${RESET}" "$short_cwd")")
fi

# Git branch (run git in the cwd reported by Claude)
if [ -n "$cwd" ] && [ -d "$cwd" ]; then
  branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    parts+=("$(printf "${GREEN}%s${RESET}" "$branch")")
  fi
fi

# 5-hour rate limit
if [ -n "$five_h" ]; then
  five_int=$(printf "%.0f" "$five_h")
  if [ "$five_int" -ge 80 ]; then
    color="$ORANGE"
  elif [ "$five_int" -ge 50 ]; then
    color="$YELLOW"
  else
    color="$GREEN"
  fi
  remaining=$(format_remaining "$five_h_reset")
  if [ -n "$remaining" ]; then
    parts+=("$(printf "${DIM}5h${RESET} ${color}%d%%${RESET} ${DIM}(%s)${RESET}" "$five_int" "$remaining")")
  else
    parts+=("$(printf "${DIM}5h${RESET} ${color}%d%%${RESET}" "$five_int")")
  fi
fi

# 7-day rate limit
if [ -n "$seven_d" ]; then
  seven_int=$(printf "%.0f" "$seven_d")
  if [ "$seven_int" -ge 80 ]; then
    color="$ORANGE"
  elif [ "$seven_int" -ge 50 ]; then
    color="$YELLOW"
  else
    color="$GREEN"
  fi
  remaining=$(format_remaining "$seven_d_reset")
  if [ -n "$remaining" ]; then
    parts+=("$(printf "${DIM}7d${RESET} ${color}%d%%${RESET} ${DIM}(%s)${RESET}" "$seven_int" "$remaining")")
  else
    parts+=("$(printf "${DIM}7d${RESET} ${color}%d%%${RESET}" "$seven_int")")
  fi
fi

# Context usage with color based on percentage (placed last)
if [ -n "$used_pct" ]; then
  used_int=$(printf "%.0f" "$used_pct")
  if [ "$used_int" -ge 80 ]; then
    color="$ORANGE"
  elif [ "$used_int" -ge 50 ]; then
    color="$YELLOW"
  else
    color="$CYAN"
  fi
  parts+=("$(printf "${DIM}ctx${RESET} ${color}%d%%${RESET}" "$used_int")")
fi

# Join parts with separator
if [ ${#parts[@]} -gt 0 ]; then
  result=""
  for i in "${!parts[@]}"; do
    if [ $i -gt 0 ]; then
      result+=" $SEPARATOR "
    fi
    result+="${parts[$i]}"
  done
  printf "%b" "$result"
fi
