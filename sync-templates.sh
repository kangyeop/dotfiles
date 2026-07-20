#!/bin/bash
# Explicitly promote personal Claude/Codex settings into their repo templates.
# Unlike sync.sh, this is opt-in because these files can contain local UI state.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$REPO_DIR/mappings.sh"

sync_template_one() {
  local repo_path="$REPO_DIR/$1"
  local personal_path="$2"

  if [ ! -f "$personal_path" ]; then
    echo "skip    $personal_path (not present locally)"
    return
  fi

  if diff -u "$repo_path" "$personal_path"; then
    echo "ok      $personal_path"
    return
  fi

  cp "$personal_path" "$repo_path"
  echo "pulled  $personal_path -> $repo_path"
}

for mapping in "${TEMPLATE_MAPPINGS[@]}"; do
  sync_template_one "${mapping%%:*}" "${mapping#*:}"
done

echo
echo "Review with: git -C \"$REPO_DIR\" diff"
