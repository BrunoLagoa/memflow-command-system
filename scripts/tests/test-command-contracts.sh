#!/usr/bin/env bash

# Validates behavioral contracts defined in each command spec.
# Tests key invariants — not just text presence, but structural guarantees
# that must hold for the system to behave as intended.
#
# Note: uses grep -E (ERE). Alternation uses bare | not \|.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SRC_DIR="${ROOT_DIR}/src"

pass_count=0
fail_count=0

assert_contains() {
  local file="$1"
  local pattern="$2"
  local label="$3"
  if grep -Eq "$pattern" "$file"; then
    printf "[PASS] %s\n" "$label"
    pass_count=$((pass_count + 1))
  else
    printf "[FAIL] %s\n" "$label"
    fail_count=$((fail_count + 1))
  fi
}

assert_not_contains() {
  local file="$1"
  local pattern="$2"
  local label="$3"
  if grep -Eq "$pattern" "$file"; then
    printf "[FAIL] %s\n" "$label"
    fail_count=$((fail_count + 1))
  else
    printf "[PASS] %s\n" "$label"
    pass_count=$((pass_count + 1))
  fi
}

# ──────────────────────────────────────────────────────────────────
# Contrato global: todos os comandos executáveis
# ──────────────────────────────────────────────────────────────────

EXECUTABLE_COMMANDS=(
  context workflow brainstorm execute plan
  review review-code review-enforce-rules
  debug prd spec refactor test-plan
  memory-init memory-save
)

printf "\n=== Contratos globais (todos os comandos) ===\n\n"

for cmd in "${EXECUTABLE_COMMANDS[@]}"; do
  file="${SRC_DIR}/${cmd}.md"
  assert_contains "$file" "^name: ${cmd}$" "/${cmd}: frontmatter name correto"
  assert_contains "$file" "license: MIT" "/${cmd}: license MIT presente"
  assert_contains "$file" "version:" "/${cmd}: version no metadata"
  assert_contains "$file" "_shared/base-output\.md" "/${cmd}: referencia base-output"
  assert_contains "$file" "_shared/base-preconditions\.md" "/${cmd}: referencia base-preconditions"
done

# ──────────────────────────────────────────────────────────────────
# Bases compartilhadas: devem ser non-executable (hidden: true)
# ──────────────────────────────────────────────────────────────────

printf "\n=== Bases normativas compartilhadas (_shared) ===\n\n"

SHARED_BASES=(base-output base-preconditions base-degraded-mode)
for base in "${SHARED_BASES[@]}"; do
  file="${SRC_DIR}/_shared/${base}.md"
  assert_contains "$file" "hidden: true" "_shared/${base}: marcado como hidden (non-executable)"
done

# ──────────────────────────────────────────────────────────────────
# /workflow — orquestrador central
# ──────────────────────────────────────────────────────────────────

printf "\n=== /workflow ===\n\n"

WORKFLOW="${SRC_DIR}/workflow.md"
assert_contains "$WORKFLOW" "decisions\.md" "workflow: base de decisão inclui decisions.md"
assert_contains "$WORKFLOW" "NÃO permitir bypass" "workflow: regra anti-bypass presente"
assert_contains "$WORKFLOW" "EXPLORAR COM /brainstorm" "workflow: roteamento para /brainstorm integrado"
assert_contains "$WORKFLOW" "Decisão tomada" "workflow: status de saída 'Decisão tomada' definido"
assert_contains "$WORKFLOW" "sempre prevalece" "workflow: decisions.md tem precedência máxima"
assert_contains "$WORKFLOW" "anti-compaction|ANTI-COMPACTION" "workflow: gate de invariantes anti-compaction presente"
assert_contains "$WORKFLOW" "pt-BR" "workflow: valida idioma pt-BR"

# ──────────────────────────────────────────────────────────────────
# /brainstorm — exploração estruturada
# ──────────────────────────────────────────────────────────────────

printf "\n=== /brainstorm ===\n\n"

BRAINSTORM="${SRC_DIR}/brainstorm.md"
assert_contains "$BRAINSTORM" "HARD-GATE" "brainstorm: HARD-GATE anti-bypass presente"
assert_contains "$BRAINSTORM" "NÃO invocar.*execute|NÃO.*execute.*implementação" "brainstorm: proíbe invocação de /execute"
assert_contains "$BRAINSTORM" "uto-revis" "brainstorm: auto-revisão presente"
assert_contains "$BRAINSTORM" "prontidão|DoD" "brainstorm: critério de prontidão (DoD) presente"
assert_contains "$BRAINSTORM" "Confirmação obrigatória de salvamento" "brainstorm: gate de salvamento presente"
assert_contains "$BRAINSTORM" "Pronto para /prd|Pronto para /spec|Pronto para /plan" "brainstorm: status de handoff definidos"
assert_contains "$BRAINSTORM" "fase 1/4|fase 2/4|fase 3/4|fase 4/4" "brainstorm: processo em 4 fases definido"

# ──────────────────────────────────────────────────────────────────
# /execute — implementação controlada
# ──────────────────────────────────────────────────────────────────

printf "\n=== /execute ===\n\n"

EXECUTE="${SRC_DIR}/execute.md"
assert_contains "$EXECUTE" "BLOQUEAR e retornar ao" "execute: bloqueia sem decisão do /workflow"
assert_contains "$EXECUTE" "NÃO decide estratégia" "execute: não assume papel de orquestrador"
assert_contains "$EXECUTE" "decisão.*workflow|workflow.*decisão" "execute: exige decisão explícita do /workflow"

# ──────────────────────────────────────────────────────────────────
# /plan — planejamento antes da execução
# ──────────────────────────────────────────────────────────────────

printf "\n=== /plan ===\n\n"

PLAN="${SRC_DIR}/plan.md"
assert_contains "$PLAN" "PLANEJAR PRIMEIRO" "plan: integrado à decisão PLANEJAR PRIMEIRO do /workflow"
assert_contains "$PLAN" "ambiguidade" "plan: bloqueia em caso de ambiguidade"
assert_contains "$PLAN" "Confirmação obrigatória de salvamento" "plan: gate de confirmação de salvamento"
assert_contains "$PLAN" "Não escreve código|NÃO escreve|não escreve código" "plan: não implementa código"

# ──────────────────────────────────────────────────────────────────
# /review e /review-code — validação de qualidade
# ──────────────────────────────────────────────────────────────────

printf "\n=== /review e /review-code ===\n\n"

REVIEW="${SRC_DIR}/review.md"
assert_contains "$REVIEW" "NÃO implementar|NÃO implementa|NÃO corrige" "review: não implementa nem corrige"
assert_contains "$REVIEW" "Aprovado|Reprovado" "review: status de saída Aprovado/Reprovado definido"

REVIEW_CODE="${SRC_DIR}/review-code.md"
assert_contains "$REVIEW_CODE" "NÃO implementa|NÃO corrige|não implementa|não corrige" "review-code: não implementa nem corrige"

# ──────────────────────────────────────────────────────────────────
# /review-enforce-rules — gate binário final
# ──────────────────────────────────────────────────────────────────

printf "\n=== /review-enforce-rules ===\n\n"

ENFORCE="${SRC_DIR}/review-enforce-rules.md"
assert_contains "$ENFORCE" "BLOQUEADO" "review-enforce-rules: status BLOQUEADO definido"
assert_contains "$ENFORCE" "^## Status$|^## Saída$|OK" "review-enforce-rules: status OK definido"
assert_contains "$ENFORCE" "NÃO aprovar parcialmente|NÃO flexibilizar|NÃO aceitar violações" "review-enforce-rules: regra de rigidez presente"
assert_contains "$ENFORCE" "qualquer dúvida|dúvida ou ambiguidade" "review-enforce-rules: dúvida = BLOQUEADO"

# ──────────────────────────────────────────────────────────────────
# /debug — diagnóstico sem correção
# ──────────────────────────────────────────────────────────────────

printf "\n=== /debug ===\n\n"

DEBUG="${SRC_DIR}/debug.md"
assert_contains "$DEBUG" "NÃO executa correções" "debug: não executa correções"
assert_contains "$DEBUG" "NÃO implementar correções|NÃO implementa" "debug: não implementa"
assert_contains "$DEBUG" "/execute|/refactor|/plan" "debug: handoff para /execute, /refactor ou /plan"

# ──────────────────────────────────────────────────────────────────
# Gates de confirmação de salvamento (prd, spec, brainstorm, plan)
# ──────────────────────────────────────────────────────────────────

printf "\n=== Gates de salvamento ===\n\n"

for cmd in prd spec plan brainstorm; do
  file="${SRC_DIR}/${cmd}.md"
  assert_contains "$file" "Confirmação obrigatória de salvamento" "/${cmd}: gate de confirmação de salvamento presente"
done

# ──────────────────────────────────────────────────────────────────
# Invariantes anti-compaction (contexto e workflow)
# ──────────────────────────────────────────────────────────────────

printf "\n=== Invariantes anti-compaction ===\n\n"

CONTEXT="${SRC_DIR}/context.md"
assert_contains "$CONTEXT" "pt-BR|pt_BR" "context: invariante de idioma pt-BR presente"
assert_contains "$CONTEXT" "anti-compaction|ANTI-COMPACTION" "context: seção anti-compaction presente"
assert_contains "$WORKFLOW" "anti-compaction|ANTI-COMPACTION" "workflow: gate de invariantes anti-compaction presente"

printf "\n=== Resultado ===\n"
printf "Total: %d passou, %d falhou\n" "$pass_count" "$fail_count"
if [[ "$fail_count" -gt 0 ]]; then
  exit 1
fi
