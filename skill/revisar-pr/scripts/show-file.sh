#!/usr/bin/env bash
# Muestra el contenido de un archivo tal como queda en la revisión:
# en modo PR lo lee de la rama origen (origin/<src>), en modo local del working tree.
# Uso: show-file.sh --out <dir> <ruta-relativa-al-repo>
set -euo pipefail

OUT=""
FILE=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --out) OUT="$2"; shift 2 ;;
    *) FILE="$1"; shift ;;
  esac
done
[[ -n "$OUT" && -n "$FILE" ]] || { echo "uso: show-file.sh --out <dir> <ruta>" >&2; exit 2; }

REF="$(jq -r '.ref' "$OUT/meta.json")"
REPO_ROOT="$(jq -r '.repoRoot' "$OUT/meta.json")"

if [[ "$REF" == "WORKTREE" ]]; then
  cat "$REPO_ROOT/$FILE"
else
  git -C "$REPO_ROOT" show "$REF:$FILE"
fi
