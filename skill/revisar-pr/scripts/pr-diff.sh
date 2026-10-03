#!/usr/bin/env bash
# Obtiene el diff a revisar (PR de Azure DevOps o rama local) y lo deja en --out.
# Uso:
#   pr-diff.sh <pr-id> [--force] --out <dir>
#   pr-diff.sh [--base <rama>] --out <dir>
# Un PR en DRAFT se rechaza salvo que se pase --force.
set -euo pipefail

ORG="https://dev.azure.com/Linktic"
DEFAULT_BASE="develop"
EXCLUDES=(':(exclude)dist/**' ':(exclude)public/**' ':(exclude)coverage/**' ':(exclude)pnpm-lock.yaml' ':(exclude)*.md')

PR_ID=""
BASE="$DEFAULT_BASE"
OUT=""
FORCE=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --base) BASE="$2"; shift 2 ;;
    --out) OUT="$2"; shift 2 ;;
    --force) FORCE=1; shift ;;
    -h|--help) sed -n '2,6p' "$0"; exit 0 ;;
    *)
      if [[ "$1" =~ ^[0-9]+$ ]]; then PR_ID="$1"; shift
      else echo "error: argumento no reconocido: $1" >&2; exit 2; fi ;;
  esac
done

[[ -n "$OUT" ]] || { echo "error: falta --out <dir>" >&2; exit 2; }
mkdir -p "$OUT"
OUT="$(cd "$OUT" && pwd)"

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || { echo "error: no estás dentro de un repositorio git" >&2; exit 1; }
cd "$REPO_ROOT"

REMOTE="$(git remote get-url origin 2>/dev/null || true)"
case "$REMOTE" in
  *core_web_bac*) PROJECT_NAME="core_web_bac"; AZ_PROJECT="419 - DEPOSITOS JUDICIALES" ;;
  *core_web_csj*) PROJECT_NAME="core_web_csj"; AZ_PROJECT="419 - RAMA DEPOSITOS JUDICIALES" ;;
  *) echo "error: este skill solo aplica a core_web_bac y core_web_csj (remote: ${REMOTE:-ninguno})" >&2; exit 1 ;;
esac

if [[ -n "$PR_ID" ]]; then
  MODE="pr"
  # stderr aparte: los WARNING de az mezclados con el JSON rompen jq.
  PR_JSON="$(az repos pr show --id "$PR_ID" --organization "$ORG" -o json 2>"$OUT/az.err")" || {
    echo "error: no se pudo obtener el PR $PR_ID desde Azure DevOps:" >&2
    tail -3 "$OUT/az.err" >&2
    echo "sugerencia: verifica el id o ejecuta 'az login' / 'az devops login'" >&2
    exit 1
  }
  PR_REPO="$(jq -r '.repository.name' <<<"$PR_JSON")"
  [[ "$PR_REPO" == "$PROJECT_NAME" ]] || { echo "error: el PR $PR_ID pertenece al repo '$PR_REPO', no a '$PROJECT_NAME'" >&2; exit 1; }

  IS_DRAFT="$(jq -r '.isDraft // false' <<<"$PR_JSON")"
  if [[ "$IS_DRAFT" == "true" && "$FORCE" -ne 1 ]]; then
    echo "PR #$PR_ID está en DRAFT: no se revisa." >&2
    echo "El autor todavía lo está armando; espera a que lo publique." >&2
    echo "sugerencia: si aun así quieres revisarlo, repite con --force" >&2
    exit 3
  fi

  SRC="$(jq -r '.sourceRefName' <<<"$PR_JSON" | sed 's#^refs/heads/##')"
  TGT="$(jq -r '.targetRefName' <<<"$PR_JSON" | sed 's#^refs/heads/##')"
  TITLE="$(jq -r '.title' <<<"$PR_JSON")"
  DESCRIPTION="$(jq -r '.description // ""' <<<"$PR_JSON")"

  git fetch --quiet origin "+refs/heads/$SRC:refs/remotes/origin/$SRC" "+refs/heads/$TGT:refs/remotes/origin/$TGT" || {
    echo "error: no se pudieron traer las ramas '$SRC' y '$TGT' desde origin" >&2; exit 1
  }
  RANGE="origin/$TGT...origin/$SRC"
  REF="origin/$SRC"
  BASE_REF="$(git merge-base "origin/$TGT" "origin/$SRC")"
  git diff "$RANGE" -- . "${EXCLUDES[@]}" > "$OUT/diff.patch"
  git diff --name-status "$RANGE" -- . "${EXCLUDES[@]}" > "$OUT/files.txt"
else
  MODE="local"
  git fetch --quiet origin "$BASE" 2>/dev/null || true
  git rev-parse --verify --quiet "origin/$BASE" >/dev/null || { echo "error: no existe origin/$BASE" >&2; exit 1; }
  MERGE_BASE="$(git merge-base "origin/$BASE" HEAD)"
  SRC="$(git branch --show-current)"
  TGT="$BASE"
  TITLE="$(git log -1 --pretty=%s)"
  DESCRIPTION=""
  REF="WORKTREE"
  BASE_REF="$MERGE_BASE"
  IS_DRAFT="false"

  git diff "$MERGE_BASE" -- . "${EXCLUDES[@]}" > "$OUT/diff.patch"
  git diff --name-status "$MERGE_BASE" -- . "${EXCLUDES[@]}" > "$OUT/files.txt"
  while IFS= read -r untracked; do
    [[ -n "$untracked" ]] || continue
    git diff --no-index -- /dev/null "$untracked" >> "$OUT/diff.patch" || true
    printf 'A\t%s\n' "$untracked" >> "$OUT/files.txt"
  done < <(git ls-files --others --exclude-standard -- . "${EXCLUDES[@]}")
fi

jq -n \
  --arg project "$PROJECT_NAME" --arg azProject "$AZ_PROJECT" --arg mode "$MODE" \
  --arg prId "$PR_ID" --arg title "$TITLE" --arg source "$SRC" --arg target "$TGT" \
  --arg ref "$REF" --arg baseRef "$BASE_REF" --arg repoRoot "$REPO_ROOT" --arg description "$DESCRIPTION" \
  --argjson isDraft "$IS_DRAFT" \
  '{project:$project, azProject:$azProject, mode:$mode, prId:$prId, title:$title, source:$source, target:$target, ref:$ref, baseRef:$baseRef, repoRoot:$repoRoot, isDraft:$isDraft, description:$description}' \
  > "$OUT/meta.json"

FILES="$(grep -c . "$OUT/files.txt" || true)"
# Del propio patch, para que cuente también los archivos no rastreados del modo local.
STAT="$(git apply --numstat "$OUT/diff.patch" 2>/dev/null | awk '{a+=$1; d+=$2} END {if (NR) printf " +%d/−%d", a, d}')"
DRAFT_TAG=""
if [[ "$IS_DRAFT" == "true" ]]; then DRAFT_TAG=" · DRAFT (revisado con --force)"; fi
echo "$PROJECT_NAME · modo $MODE${PR_ID:+ · PR #$PR_ID}$DRAFT_TAG · $SRC → $TGT · $FILES archivos ·${STAT:- sin cambios}"
echo "salida: $OUT (meta.json, files.txt, diff.patch)"
