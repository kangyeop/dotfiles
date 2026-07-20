#!/bin/bash
# Symlinks this repo's shared config files into place, copies personal config
# defaults when needed, and installs the couple of external packages this config
# depends on. Idempotent — safe to re-run.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d%H%M%S)"

source "$REPO_DIR/mappings.sh"

link_one() {
  local src="$REPO_DIR/$1"
  local dest="$2"

  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    echo "ok      $dest"
    return
  fi

  mkdir -p "$(dirname "$dest")"

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    mkdir -p "$BACKUP_DIR/$(dirname "${dest#$HOME/}")"
    mv "$dest" "$BACKUP_DIR/${dest#$HOME/}"
    echo "backup  $dest -> $BACKUP_DIR/${dest#$HOME/}"
  fi

  ln -s "$src" "$dest"
  echo "linked  $dest -> $src"
}

copy_template_one() {
  local src="$REPO_DIR/$1"
  local dest="$2"

  mkdir -p "$(dirname "$dest")"

  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    rm "$dest"
    cp "$src" "$dest"
    echo "copied  $src -> $dest (replaced symlink)"
  elif [ -e "$dest" ] || [ -L "$dest" ]; then
    echo "keep    $dest (existing personal config)"
  else
    cp "$src" "$dest"
    echo "copied  $src -> $dest"
  fi
}

for mapping in "${MAPPINGS[@]}"; do
  link_one "${mapping%%:*}" "${mapping#*:}"
done

for mapping in "${TEMPLATE_MAPPINGS[@]}"; do
  copy_template_one "${mapping%%:*}" "${mapping#*:}"
done

if command -v agent-browser >/dev/null 2>&1; then
  echo "ok      agent-browser (npm)"
else
  npm install -g agent-browser
  echo "installed agent-browser (npm)"
fi
