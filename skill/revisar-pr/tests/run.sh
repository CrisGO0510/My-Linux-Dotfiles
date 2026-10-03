#!/usr/bin/env bash
# Test de regresión de pr-diff.sh + pre-scan.py (modo local) sobre un repo sintético.
# Uso:
#   run.sh               compara la salida con esperado.txt
#   run.sh --actualizar  regenera esperado.txt (revisar el diff antes de commitear)
#
# Fixtures:
#   fixtures/base/        estado de develop
#   fixtures/rama/        archivos que la rama añade o sobrescribe (se commitean)
#   fixtures/sin-commit/  archivos que quedan sin rastrear (prueba el modo local con untracked)
#   fixtures/renombrados.txt  pares "<origen> <destino>" que la rama aplica con git mv
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
SCRIPTS="$HERE/../scripts"
FIX="$HERE/fixtures"
EXPECTED="$HERE/esperado.txt"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# pr-diff.sh decide el proyecto por el remote: tiene que contener core_web_bac.
git init -q --bare "$TMP/core_web_bac.git"
git clone -q "$TMP/core_web_bac.git" "$TMP/repo" 2>/dev/null
cd "$TMP/repo"
git config user.email test@test && git config user.name test

git switch -qc develop
cp -r "$FIX/base/." .
git add -A && git commit -qm base && git push -q origin develop

git switch -qc feat/test
while read -r from to; do
  [[ -z "$from" || "$from" == \#* ]] && continue
  git mv "$from" "$to"
done < "$FIX/renombrados.txt"
cp -r "$FIX/rama/." .
git add -A && git commit -qm rama
cp -r "$FIX/sin-commit/." .

ACTUAL="$TMP/actual.txt"
{
  "$SCRIPTS/pr-diff.sh" --out "$TMP/out" | head -1
  "$SCRIPTS/pre-scan.py" --out "$TMP/out" 2>&1
} > "$ACTUAL"

if [[ "${1:-}" == "--actualizar" ]]; then
  cp "$ACTUAL" "$EXPECTED"
  echo "esperado.txt actualizado ($(wc -l < "$EXPECTED") líneas)"
  exit 0
fi

if diff -u --label esperado "$EXPECTED" --label actual "$ACTUAL"; then
  echo "ok: $(grep -c '\[' "$ACTUAL") hallazgos, igual que esperado.txt"
else
  echo "FALLO: la salida cambió (si es intencionado: run.sh --actualizar)" >&2
  exit 1
fi
