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
assert_contains "$WORKFLOW" "NÃO permitir bypass|DO NOT allow bypass" "workflow: regra anti-bypass presente"
assert_contains "$WORKFLOW" "EXPLORAR COM /brainstorm|EXPLORE WITH /brainstorm" "workflow: roteamento para /brainstorm integrado"
assert_contains "$WORKFLOW" "Decisão tomada|Decision made" "workflow: status de saída 'Decisão tomada' definido"
assert_contains "$WORKFLOW" "sempre prevalece|always prevails" "workflow: decisions.md tem precedência máxima"
assert_contains "$WORKFLOW" "anti-compaction|ANTI-COMPACTION" "workflow: gate de invariantes anti-compaction presente"
assert_contains "$WORKFLOW" "pt-BR" "workflow: valida idioma pt-BR"
assert_contains "$WORKFLOW" "Premissas e ambiguidades|Assumptions and ambiguities" "workflow: exige seção de premissas e ambiguidades"
assert_contains "$WORKFLOW" "NÃO escolher interpretação silenciosamente|não escolher interpretação silenciosamente|DO NOT silently choose an interpretation|choose interpretation silently" "workflow: proíbe interpretação silenciosa em ambiguidades"

# ──────────────────────────────────────────────────────────────────
# /brainstorm — exploração estruturada
# ──────────────────────────────────────────────────────────────────

printf "\n=== /brainstorm ===\n\n"

BRAINSTORM="${SRC_DIR}/brainstorm.md"
assert_contains "$BRAINSTORM" "HARD-GATE" "brainstorm: HARD-GATE anti-bypass presente"
assert_contains "$BRAINSTORM" "NÃO invocar.*execute|NÃO.*execute.*implementação|DO NOT invoke.*execute|DO NOT.*execute.*implement" "brainstorm: proíbe invocação de /execute"
assert_contains "$BRAINSTORM" "uto-revis|self-review" "brainstorm: auto-revisão presente"
assert_contains "$BRAINSTORM" "prontidão|DoD" "brainstorm: critério de prontidão (DoD) presente"
assert_contains "$BRAINSTORM" "Confirmação obrigatória de salvamento|Mandatory save confirmation" "brainstorm: gate de salvamento presente"
assert_contains "$BRAINSTORM" "Pronto para /prd|Pronto para /spec|Pronto para /plan|Ready for /prd|Ready for /spec|Ready for /plan" "brainstorm: status de handoff definidos"
assert_contains "$BRAINSTORM" "fase 1/4|fase 2/4|fase 3/4|fase 4/4" "brainstorm: processo em 4 fases definido"

# ──────────────────────────────────────────────────────────────────
# /execute — implementação controlada
# ──────────────────────────────────────────────────────────────────

printf "\n=== /execute ===\n\n"

EXECUTE="${SRC_DIR}/execute.md"
assert_contains "$EXECUTE" "BLOQUEAR e retornar ao|BLOCK and return to" "execute: bloqueia sem decisão do /workflow"
assert_contains "$EXECUTE" "NÃO decide estratégia|DOES NOT decide strategy|does NOT decide strategy" "execute: não assume papel de orquestrador"
assert_contains "$EXECUTE" "decisão.*workflow|workflow.*decisão|decision.*workflow|workflow.*decision" "execute: exige decisão explícita do /workflow"
assert_contains "$EXECUTE" "Premissas explícitas|Explicit assumptions|Explicit premises" "execute: exige premissas explícitas antes de codar"
assert_contains "$EXECUTE" "Simplicidade primeiro|Simplicity first" "execute: prioriza simplicidade"
assert_contains "$EXECUTE" "mudanças cirúrgicas|vínculo direto com a solicitação|surgical changes|directly linked to the request" "execute: exige alterações cirúrgicas"
assert_contains "$EXECUTE" "Execução orientada a metas|objetivo verificável|Goal-driven execution|verifiable objective" "execute: exige execução orientada a metas"

# ──────────────────────────────────────────────────────────────────
# /plan — planejamento antes da execução
# ──────────────────────────────────────────────────────────────────

printf "\n=== /plan ===\n\n"

PLAN="${SRC_DIR}/plan.md"
assert_contains "$PLAN" "PLANEJAR PRIMEIRO|PLAN FIRST" "plan: integrado à decisão PLANEJAR PRIMEIRO do /workflow"
assert_contains "$PLAN" "ambiguidade|ambiguity|ambiguous" "plan: bloqueia em caso de ambiguidade"
assert_contains "$PLAN" "Confirmação obrigatória de salvamento|Mandatory save confirmation" "plan: gate de confirmação de salvamento"
assert_contains "$PLAN" "Não escreve código|NÃO escreve|não escreve código|Do not write code|DOES NOT write code" "plan: não implementa código"
assert_contains "$PLAN" "Premissas explícitas|Explicit assumptions|Explicit premises" "plan: exige premissas explícitas antes do plano"
assert_contains "$PLAN" "Passo -> verificar|<passo>.*verificar|Step -> verify|<step>.*verify" "plan: passos incluem verificação objetiva"

# ──────────────────────────────────────────────────────────────────
# /review e /review-code — validação de qualidade
# ──────────────────────────────────────────────────────────────────

printf "\n=== /review e /review-code ===\n\n"

REVIEW="${SRC_DIR}/review.md"
assert_contains "$REVIEW" "NÃO implementar|NÃO implementa|NÃO corrige|DO NOT implement|DOES NOT implement|DOES NOT auto-fix" "review: não implementa nem corrige"
assert_contains "$REVIEW" "Aprovado|Reprovado|Approved|Failed" "review: status de saída Aprovado/Reprovado definido"
assert_contains "$REVIEW" "Escopo das mudanças|surgical check" "review: valida escopo cirúrgico das mudanças"

REVIEW_CODE="${SRC_DIR}/review-code.md"
assert_contains "$REVIEW_CODE" "NÃO implementa|NÃO corrige|não implementa|não corrige|DO NOT implement|DO NOT auto-fix" "review-code: não implementa nem corrige"
assert_contains "$REVIEW_CODE" "Simplicidade e overengineering|Simplicity and overengineering" "review-code: valida simplicidade técnica"

# ──────────────────────────────────────────────────────────────────
# /review-enforce-rules — gate binário final
# ──────────────────────────────────────────────────────────────────

printf "\n=== /review-enforce-rules ===\n\n"

ENFORCE="${SRC_DIR}/review-enforce-rules.md"
assert_contains "$ENFORCE" "BLOQUEADO" "review-enforce-rules: status BLOQUEADO definido"
assert_contains "$ENFORCE" "^## Status$|^## Saída$|OK" "review-enforce-rules: status OK definido"
assert_contains "$ENFORCE" "NÃO aprovar parcialmente|NÃO flexibilizar|NÃO aceitar violações|DO NOT partially approve|DO NOT relax rules|DO NOT accept violations" "review-enforce-rules: regra de rigidez presente"
assert_contains "$ENFORCE" "qualquer dúvida|dúvida ou ambiguidade|any doubt|doubt or ambiguity" "review-enforce-rules: dúvida = BLOQUEADO"

# ──────────────────────────────────────────────────────────────────
# /debug — diagnóstico sem correção
# ──────────────────────────────────────────────────────────────────

printf "\n=== /debug ===\n\n"

DEBUG="${SRC_DIR}/debug.md"
assert_contains "$DEBUG" "NÃO executa correções|DOES NOT execute fixes|DO NOT implement fixes" "debug: não executa correções"
assert_contains "$DEBUG" "NÃO implementar correções|NÃO implementa|DO NOT implement fixes|DO NOT implement" "debug: não implementa"
assert_contains "$DEBUG" "/execute|/refactor|/plan" "debug: handoff para /execute, /refactor ou /plan"

# ──────────────────────────────────────────────────────────────────
# /test-plan — plano de testes executável e verificável
# ──────────────────────────────────────────────────────────────────

printf "\n=== /test-plan ===\n\n"

TEST_PLAN="${SRC_DIR}/test-plan.md"
assert_contains "$TEST_PLAN" "Critério de aprovação por cenário|Approval criteria per scenario" "test-plan: exige critério objetivo por cenário"
assert_contains "$TEST_PLAN" "loop de validação|reproduzir cenário|validation loop|reproduce scenario" "test-plan: exige loop de validação"

# ──────────────────────────────────────────────────────────────────
# /memory-save — persistência e lifecycle de memória
# ──────────────────────────────────────────────────────────────────

printf "\n=== /memory-save ===\n\n"

MEMORY_SAVE="${SRC_DIR}/memory-save.md"
assert_contains "$MEMORY_SAVE" "Confirmação obrigatória antes de escrever|Mandatory confirmation before writing" "memory-save: gate de confirmação antes de escrever"
assert_contains "$MEMORY_SAVE" "Score de relevância \(0–100\)|Score de relevância|Relevance Score \(0–100\)|relevance score" "memory-save: score de relevância definido"
assert_contains "$MEMORY_SAVE" "0–20.*Não salvar|0–20" "memory-save: limiar mínimo para não salvar"
assert_contains "$MEMORY_SAVE" "Reforço|reforço|Reinforcement" "memory-save: regra de reforço de decisão existente"
assert_contains "$MEMORY_SAVE" "session-memory\.md" "memory-save: gerencia session-memory.md"
assert_contains "$MEMORY_SAVE" "decision-suggestions\.md" "memory-save: gerencia decision-suggestions.md"
assert_contains "$MEMORY_SAVE" "quality-metrics\.md" "memory-save: gerencia quality-metrics.md"
assert_contains "$MEMORY_SAVE" "review_result|/review" "memory-save: integração com /review"
assert_contains "$MEMORY_SAVE" "NÃO salvar sem confirmação|NÃO salvar sem confirmação explícita|DO NOT save without explicit confirmation" "memory-save: proíbe salvar sem confirmação"
assert_contains "$MEMORY_SAVE" "NÃO duplicar|mesclar|DO NOT duplicate|merge" "memory-save: regra anti-duplicação"
assert_contains "$MEMORY_SAVE" "Session-memory limpo|session-memory limpo|Session-memory cleared" "memory-save: limpeza de session-memory após save"
assert_contains "$MEMORY_SAVE" "Salvo|Não necessário|Bloqueado|Saved|Not required|Blocked" "memory-save: status de saída definidos"
assert_contains "$MEMORY_SAVE" "500–1000 tokens|500-1000" "memory-save: limite de tokens para session-memory durante sessão"
assert_contains "$MEMORY_SAVE" "Critérios de eviction \(insights\)|Critérios de eviction|Eviction criteria \(insights\)|Eviction criteria" "memory-save: critérios de eviction definidos"
assert_contains "$MEMORY_SAVE" "Ignoradas consecutivas|Consecutive ignores" "memory-save: rastreio de sugestões ignoradas"
assert_contains "$MEMORY_SAVE" "Ignoradas consecutivas.*≥.*3|≥ \\*\\*3\\*\\*" "memory-save: expiração após 3 ignoradas"
assert_contains "$MEMORY_SAVE" "formato legado|migrar|legacy format|migrate" "memory-save: migração de quality-metrics legado"
assert_contains "$MEMORY_SAVE" "dashboard estruturado|dashboard" "memory-save: framing de decisions.md como dashboard"
assert_contains "$MEMORY_SAVE" "Em caso de dúvida|em caso de dúvida|if in doubt" "memory-save: princípio em dúvida não salvar"
assert_contains "$MEMORY_SAVE" "decidimos que|a partir de agora|definido que|we decided that|from now on|defined that" "memory-save: padrões extras de detecção"
assert_contains "$MEMORY_SAVE" "Somar apenas|somar.*apenas|não duplicar critérios|add .*only|do not duplicate equivalent criteria" "memory-save: regras de cálculo de score"

MEMORY_INIT="${SRC_DIR}/memory-init.md"
assert_contains "$MEMORY_INIT" "decision-suggestions\.md" "memory-init: bootstrap inclui decision-suggestions.md"
assert_contains "$MEMORY_INIT" "## Execuções|## Executions|## KPIs|## Snapshot atual|## Current snapshot|## Observações|## Observations" "memory-init: quality-metrics alinhado ao memory-save"
assert_contains "$MEMORY_INIT" "## Arquivadas|## Archived" "memory-init: decision-suggestions inclui seção Arquivadas"

# ──────────────────────────────────────────────────────────────────
# Gates de confirmação de salvamento (prd, spec, brainstorm, plan)
# ──────────────────────────────────────────────────────────────────

printf "\n=== Gates de salvamento ===\n\n"

for cmd in prd spec plan brainstorm; do
  file="${SRC_DIR}/${cmd}.md"
  assert_contains "$file" "Confirmação obrigatória de salvamento|Mandatory save confirmation" "/${cmd}: gate de confirmação de salvamento presente"
done

# ──────────────────────────────────────────────────────────────────
# Invariantes anti-compaction (contexto e workflow)
# ──────────────────────────────────────────────────────────────────

printf "\n=== Invariantes anti-compaction ===\n\n"

CONTEXT="${SRC_DIR}/context.md"
assert_contains "$CONTEXT" "pt-BR|pt_BR" "context: invariante de idioma pt-BR presente"
assert_contains "$CONTEXT" "anti-compaction|ANTI-COMPACTION" "context: seção anti-compaction presente"
assert_contains "$CONTEXT" "DO NOT ask the user to run .*/context.*again|não solicitar.*execute .*/context.*novamente|NÃO solicitar.*execute .*/context.*novamente" "context: não pede /context novamente quando ativo"
assert_contains "$CONTEXT" "immediately execute.*context.*memory.*metrics.*skills|executar imediatamente.*contexto.*memória.*métricas.*skills" "context: executa carregamento quando invocado"
assert_contains "$WORKFLOW" "anti-compaction|ANTI-COMPACTION" "workflow: gate de invariantes anti-compaction presente"

BASE_PRECONDITIONS="${SRC_DIR}/_shared/base-preconditions.md"
assert_contains "$BASE_PRECONDITIONS" "Early activation rule|Regra de ativação antecipada" "base-preconditions: exceção antecipada para comando ativo"
assert_contains "$BASE_PRECONDITIONS" "DO NOT ask the user to run .*/context.*again|NÃO solicitar.*execute .*/context.*novamente" "base-preconditions: /context ativo não pede reexecução"

printf "\n=== Resultado ===\n"
printf "Total: %d passou, %d falhou\n" "$pass_count" "$fail_count"
if [[ "$fail_count" -gt 0 ]]; then
  exit 1
fi
