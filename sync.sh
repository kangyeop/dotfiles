#!/bin/bash
# Opposite of install.sh: pulls this machine's shared config back into the repo.
# Personal config templates are intentionally one-way and excluded.
# Useful when a target file drifted from a symlink into a real file (an editor's
# atomic-save can replace a symlink with a plain file) and picked up local edits.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$REPO_DIR/mappings.sh"

sync_one() {
  local src="$REPO_DIR/$1"
  local dest="$2"

  if [ ! -e "$dest" ] && [ ! -L "$dest" ]; then
    echo "skip    $dest (not present locally)"
    return
  fi

  if [ -L "$dest" ]; then
    if [ "$(readlink "$dest")" = "$src" ]; then
      echo "ok      $dest"
    else
      echo "warn    $dest is a symlink but not to $src -- run install.sh to fix"
    fi
    return
  fi

  if diff -rq "$dest" "$src" >/dev/null 2>&1; then
    echo "relink  $dest (content already matched repo)"
  else
    echo "pull    $dest -> $src (repo updated with local changes)"
    rm -rf "$src"
    cp -r "$dest" "$src"
  fi

  rm -rf "$dest"
  ln -s "$src" "$dest"
}

for mapping in "${MAPPINGS[@]}"; do
  sync_one "${mapping%%:*}" "${mapping#*:}"
done

echo
echo "Review with: git -C \"$REPO_DIR\" diff"
