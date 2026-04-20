#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

assert_contains() {
  local file="$1"
  local pattern="$2"
  local label="$3"
  if grep -Eq "$pattern" "$file"; then
    printf "[PASS] %s\n" "$label"
  else
    printf "[FAIL] %s\n" "$label"
    exit 1
  fi
}

assert_not_contains() {
  local file="$1"
  local pattern="$2"
  local label="$3"
  if grep -Eq "$pattern" "$file"; then
    printf "[FAIL] %s\n" "$label"
    exit 1
  else
    printf "[PASS] %s\n" "$label"
  fi
}

assert_contains "$ROOT_DIR/README.md" "/review-code" "README.md inclui /review-code no fluxo público"
assert_contains "$ROOT_DIR/README.pt-BR.md" "/review-code" "README.pt-BR.md inclui /review-code no fluxo público"
assert_contains "$ROOT_DIR/src/workflow.md" "NÃO permitir bypass" "workflow mantém regra explícita de anti-bypass"
assert_contains "$ROOT_DIR/src/execute.md" "BLOQUEAR e retornar ao" "execute bloqueia sem decisão do workflow"
assert_not_contains "$ROOT_DIR/src/context.md" "^# Próximos passos" "context usa heading de próximos passos no padrão base-output"

printf "Validação de consistência docs/fluxo concluída.\n"
