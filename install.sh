#!/bin/bash
# Symlinks this repo's config files into place. Idempotent — safe to re-run.
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

for mapping in "${MAPPINGS[@]}"; do
  link_one "${mapping%%:*}" "${mapping#*:}"
done
