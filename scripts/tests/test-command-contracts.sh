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

assert_order() {
  local file="$1"
  local first_pattern="$2"
  local second_pattern="$3"
  local label="$4"
  local first_line second_line
  first_line="$(grep -nE "$first_pattern" "$file" | head -n 1 | cut -d: -f1 || true)"
  second_line="$(grep -nE "$second_pattern" "$file" | head -n 1 | cut -d: -f1 || true)"
  if [[ -n "$first_line" && -n "$second_line" && "$first_line" -lt "$second_line" ]]; then
    printf "[PASS] %s\n" "$label"
    pass_count=$((pass_count + 1))
  else
    printf "[FAIL] %s\n" "$label"
    fail_count=$((fail_count + 1))
  fi
}

# ──────────────────────────────────────────────────────────────────
# Contrato global: todos os comandos executáveis
# ──────────────────────────────────────────────────────────────────

EXECUTABLE_COMMANDS=(
  context workflow brainstorm execute plan
  review review-code review-enforce-rules
  debug prd spec refactor test-plan
  memory-init memory-save retro
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

SHARED_BASES=(base-output base-preconditions base-degraded-mode base-domain-model base-subagents target-adapter target-adapter.claude target-adapter.cursor target-adapter.vscode)
for base in "${SHARED_BASES[@]}"; do
  file="${SRC_DIR}/_shared/${base}.md"
  assert_contains "$file" "hidden: true" "_shared/${base}: marcado como hidden (non-executable)"
done

# ──────────────────────────────────────────────────────────────────
# /workflow — orquestrador central
# ──────────────────────────────────────────────────────────────────

# ──────────────────────────────────────────────────────────────────
# Modelo de domínio (glossário e ADRs)
# ──────────────────────────────────────────────────────────────────

printf "\n=== Modelo de domínio ===\n\n"

DOMAIN_MODEL="${SRC_DIR}/_shared/base-domain-model.md"
assert_contains "$DOMAIN_MODEL" "\.agents/domain/GLOSSARY\.md" "base-domain-model: glossário em .agents/domain/GLOSSARY.md"
assert_contains "$DOMAIN_MODEL" "\.agents/domain/adr/" "base-domain-model: ADRs em .agents/domain/adr/"
assert_contains "$DOMAIN_MODEL" "NEVER write to .*\.agents/domain/.* silently|NUNCA escrever em .*\.agents/domain/.* silenciosamente" "base-domain-model: escrita exige confirmação"
assert_contains "$DOMAIN_MODEL" "Hard to reverse|Difícil de reverter" "base-domain-model: critério ADR difícil de reverter"
assert_contains "$DOMAIN_MODEL" "Surprising without context|Surpreendente sem contexto" "base-domain-model: critério ADR surpreendente"
assert_contains "$DOMAIN_MODEL" "real trade-off|trade-off real" "base-domain-model: critério ADR trade-off real"
assert_contains "$DOMAIN_MODEL" "decisions\.md" "base-domain-model: relação explícita com decisions.md"

for cmd in context brainstorm spec plan execute test-plan debug review-code workflow; do
  assert_contains "${SRC_DIR}/${cmd}.md" "^- \`_shared/base-domain-model\.md\`$" "/${cmd}: referencia base-domain-model"
done

CONTEXT_DOMAIN="${SRC_DIR}/context.md"
assert_contains "$CONTEXT_DOMAIN" "only the titles|somente os títulos" "context: carrega apenas títulos dos ADRs"
assert_contains "$CONTEXT_DOMAIN" "DO NOT create domain files|NÃO criar arquivos de domínio" "context: não cria arquivos de domínio"

# ──────────────────────────────────────────────────────────────────
# Orquestração com ou sem subagents
# ──────────────────────────────────────────────────────────────────

printf "\n=== Orquestração com subagents ===\n\n"

SUBAGENTS="${SRC_DIR}/_shared/base-subagents.md"
assert_contains "$SUBAGENTS" "default is \*\*Without subagents\*\*|padrão é \*\*Sem subagents\*\*" "base-subagents: padrão é sem subagents"
assert_contains "$SUBAGENTS" "decided in .*/workflow.*for each new task|decidido no .*/workflow.*a cada nova tarefa" "base-subagents: modo decidido no /workflow por tarefa"
assert_contains "$SUBAGENTS" "sequential fallback|fallback sequencial" "base-subagents: fallback sequencial sem bloquear"
assert_contains "$SUBAGENTS" "Allowed uses \(closed list\)|Usos permitidos \(lista fechada\)" "base-subagents: lista fechada de usos"
assert_contains "$SUBAGENTS" "single writer|único escritor" "base-subagents: agente principal é único escritor do plano"
assert_contains "$SUBAGENTS" "write to .*\.agents/memory/.* or .*\.agents/domain/|escrever em .*\.agents/memory/.* ou .*\.agents/domain/" "base-subagents: subagent não escreve memória/domínio"
assert_contains "$SUBAGENTS" "Do not trust blindly|Não confiar cegamente" "base-subagents: relatórios verificados pelo agente principal"
assert_contains "$SUBAGENTS" "runSubagent" "base-subagents: capacidade VSCode documentada"
assert_contains "$SUBAGENTS" "Task \(.general., .explore.\)" "base-subagents: capacidade OpenCode documentada"

for adapter in target-adapter target-adapter.claude target-adapter.cursor target-adapter.vscode; do
  assert_contains "${SRC_DIR}/_shared/${adapter}.md" "^## Subagents$" "_shared/${adapter}: seção Subagents presente"
done

for cmd in workflow brainstorm spec plan execute debug refactor review-code retro; do
  assert_contains "${SRC_DIR}/${cmd}.md" "^- \`_shared/base-subagents\.md\`$" "/${cmd}: referencia base-subagents"
done

WORKFLOW_SUB="${SRC_DIR}/workflow.md"
assert_contains "$WORKFLOW_SUB" "Step 5\.1 — Orchestration mode|Etapa 5\.1 — Modo de orquestração" "workflow: etapa de modo de orquestração"
assert_contains "$WORKFLOW_SUB" "\*\*Sem subagents \(Recomendado\)\*\*" "workflow: sem subagents é a opção recomendada padrão"
assert_contains "$WORKFLOW_SUB" "new task → new question|nova tarefa → nova pergunta" "workflow: pergunta a cada nova tarefa"
assert_contains "$WORKFLOW_SUB" "Orquestração: Com subagents / Sem subagents" "workflow: estratégia registra orquestração"

EXECUTE_SUB="${SRC_DIR}/execute.md"
assert_contains "$EXECUTE_SUB" "Frontier implementation with subagents|Implementação da fronteira com subagents" "execute: implementação da fronteira com subagents"
assert_contains "$EXECUTE_SUB" "worktree" "execute: isolamento por worktree"
assert_contains "$EXECUTE_SUB" "\*\*disjoint\*\*|\*\*disjuntos\*\*" "execute: tarefas paralelas com arquivos disjuntos"
assert_contains "$EXECUTE_SUB" "DOES NOT push|NÃO faz push" "execute: integrador não faz push sem confirmação"

assert_contains "${SRC_DIR}/review-code.md" "two subagents in the same message|dois subagents na mesma mensagem" "review-code: eixos em subagents paralelos"
assert_contains "${SRC_DIR}/debug.md" "probes do \*\*not\*\* run in parallel|sondas \*\*não\*\* rodam em paralelo" "debug: sondas não rodam em paralelo"

# ──────────────────────────────────────────────────────────────────
# Modo mapa (/brainstorm), /refactor e /retro
# ──────────────────────────────────────────────────────────────────

printf "\n=== Modo mapa, /refactor e /retro ===\n\n"

BRAINSTORM_MAP="${SRC_DIR}/brainstorm.md"
assert_contains "$BRAINSTORM_MAP" "Map mode \(multi-session effort\)|Modo mapa \(esforço multi-sessão\)" "brainstorm: modo mapa presente"
assert_contains "$BRAINSTORM_MAP" "\.agents/docs/maps/" "brainstorm: mapa salvo em .agents/docs/maps/"
assert_contains "$BRAINSTORM_MAP" "NEVER activate automatically|NUNCA ativar automaticamente" "brainstorm: modo mapa não ativa sozinho"
assert_contains "$BRAINSTORM_MAP" "One ticket per session|Um ticket por sessão" "brainstorm: um ticket por sessão"
assert_contains "$BRAINSTORM_MAP" "Tipo: pesquisa \| protótipo \| entrevista \| tarefa" "brainstorm: tipos de ticket definidos"
assert_contains "$BRAINSTORM_MAP" "Mapa atualizado" "brainstorm: status Mapa atualizado"
assert_contains "${SRC_DIR}/spec.md" "\.agents/docs/maps/" "spec: aceita mapa concluído como fonte"

REFACTOR="${SRC_DIR}/refactor.md"
assert_contains "$REFACTOR" "Deletion test|Teste de deleção" "refactor: teste de deleção"
assert_contains "$REFACTOR" "Design vocabulary|Vocabulário de design" "refactor: vocabulário de módulos profundos"
assert_contains "$REFACTOR" "One adapter = hypothetical seam|Um adaptador = seam hipotético" "refactor: regra de seam real vs hipotético"
assert_contains "$REFACTOR" "hot spots|pontos quentes" "refactor: prioriza pontos quentes do histórico"
assert_contains "$REFACTOR" "DO NOT propose interfaces before the choice|NÃO propor interfaces antes da escolha" "refactor: não propõe interface antes da escolha"
assert_contains "$REFACTOR" "Parallel design|Design em paralelo" "refactor: design em paralelo com subagents"

RETRO="${SRC_DIR}/retro.md"
assert_contains "$RETRO" "deterministic check|checagem determinística" "retro: erro mecânico vira checagem determinística"
assert_contains "$RETRO" "DO NOT change code|NÃO alterar código" "retro: não altera código"
assert_contains "$RETRO" "\*\*Alta\*\*.*\*\*Média\*\*.*\*\*Baixa\*\*" "retro: ordena por severidade"
assert_contains "$RETRO" "DOES NOT replace .*/memory-save|NÃO substitui .*/memory-save" "retro: não substitui /memory-save"
assert_contains "$RETRO" "Navigation|Navegação" "retro: categoria navegação"

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
assert_contains "$BRAINSTORM" "Question rounds|Rodadas de perguntas" "brainstorm: perguntas em rodadas por fronteira"
assert_contains "$BRAINSTORM" "Frontier|Fronteira" "brainstorm: define fronteira de decisões"
assert_contains "$BRAINSTORM" "Facts are the agent's job|Fatos são trabalho do agente" "brainstorm: fatos são levantados pelo agente"
assert_contains "$BRAINSTORM" "\(Recomendado\)" "brainstorm: opção recomendada marcada"
assert_not_contains "$BRAINSTORM" "one question per message|uma pergunta por mensagem" "brainstorm: não força uma pergunta por mensagem"
assert_contains "$BRAINSTORM" "Domain language|Linguagem do domínio" "brainstorm: análise registra linguagem do domínio"

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
assert_contains "$EXECUTE" "\*\*frontier\*\*|\*\*fronteira\*\*" "execute: escolhe próxima tarefa pela fronteira"
assert_contains "$EXECUTE" "NEVER start a task with a pending blocker|NUNCA iniciar tarefa com bloqueio pendente" "execute: não inicia tarefa bloqueada"
assert_contains "$EXECUTE" "TDD mode|Modo TDD" "execute: modo TDD em seams acordados"
assert_contains "$EXECUTE" "red → green" "execute: ciclo red → green"
assert_contains "$EXECUTE" "\[DEBUG-" "execute: checklist de limpeza remove instrumentação [DEBUG-]"

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
assert_contains "$PLAN" "Vertical slices|Fatias verticais" "plan: tarefas em fatias verticais"
assert_contains "$PLAN" "Bloqueado por:" "plan: tarefas declaram arestas de bloqueio"
assert_contains "$PLAN" "expand → migrate → contract" "plan: refactor amplo em expand-migrate-contract"
assert_contains "$PLAN" "Breakdown review with the user|Revisão da quebra com o usuário" "plan: quebra revisada com o usuário"

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
assert_contains "$REVIEW_CODE" "Axis 1 — Standards|Eixo 1 — Padrões" "review-code: eixo Padrões presente"
assert_contains "$REVIEW_CODE" "Axis 2 — Spec|Eixo 2 — Spec" "review-code: eixo Spec presente"
assert_contains "$REVIEW_CODE" "DO NOT merge or re-rank findings across axes|NÃO mesclar nem re-ranquear achados entre eixos" "review-code: eixos não são mesclados"
assert_contains "$REVIEW_CODE" "git diff <fixed-point>\.\.\.HEAD|git diff <ponto-fixo>\.\.\.HEAD" "review-code: diff contra ponto fixo"
assert_contains "$REVIEW_CODE" "Feature Envy" "review-code: baseline de code smells presente"
assert_contains "$REVIEW_CODE" "the repo overrides|o repo prevalece" "review-code: padrão do repo prevalece sobre baseline"

# ──────────────────────────────────────────────────────────────────
# /spec — síntese, seams e fora de escopo
# ──────────────────────────────────────────────────────────────────

printf "\n=== /spec ===\n\n"

SPEC="${SRC_DIR}/spec.md"
assert_contains "$SPEC" "Synthesis mode|Modo síntese" "spec: modo síntese a partir de /brainstorm"
assert_contains "$SPEC" "DO NOT interview the user again|NÃO\*\* entrevistar o usuário novamente" "spec: modo síntese não entrevista novamente"
assert_contains "$SPEC" "Test seams|Pontos de teste \(seams\)" "spec: define seams de teste"
assert_contains "$SPEC" "confirm the seams with the user|confirmar os seams com o usuário" "spec: seams confirmados com o usuário"
assert_contains "$SPEC" "## 12\. Out of scope|## 12\. Fora de escopo" "spec: seção fora de escopo"

# ──────────────────────────────────────────────────────────────────
# /test-plan — seams e anti-padrões
# ──────────────────────────────────────────────────────────────────

printf "\n=== /test-plan ===\n\n"

TEST_PLAN="${SRC_DIR}/test-plan.md"
assert_contains "$TEST_PLAN" "Test seams \(MANDATORY\)|Seams de teste \(OBRIGATÓRIO\)" "test-plan: parte dos seams de teste"
assert_contains "$TEST_PLAN" "Tautological|Tautológico" "test-plan: anti-padrão tautológico"
assert_contains "$TEST_PLAN" "Implementation-coupled|Acoplado à implementação" "test-plan: anti-padrão acoplado à implementação"

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
assert_contains "$DEBUG" "Phase 1 — Feedback loop|Fase 1 — Feedback loop" "debug: feedback loop obrigatório"
assert_contains "$DEBUG" "red-capable|capaz de ficar vermelho" "debug: loop precisa ficar vermelho no bug"
assert_contains "$DEBUG" "3 to 5 ranked hypotheses|3 a 5 hipóteses ranqueadas" "debug: 3 a 5 hipóteses ranqueadas"
assert_contains "$DEBUG" "falsifiable|falsificável" "debug: hipóteses falsificáveis"
assert_contains "$DEBUG" "\[DEBUG-" "debug: instrumentação marcada com prefixo"
assert_contains "$DEBUG" "<REDACTED>" "debug: mascara segredos"
assert_order "$DEBUG" "Phase 1 — Feedback loop|Fase 1 — Feedback loop" "Phase 3 — Hypotheses|Fase 3 — Hipóteses" "debug: loop vem antes das hipóteses"

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
assert_not_contains "$CONTEXT" "\\(mantido\\)|\\(maintained\\)" "context: não mantém placeholder de integração MCP"
assert_not_contains "$CONTEXT" "default behavior" "context: fallback sem placeholder genérico"
assert_contains "$CONTEXT" "DO NOT block .*/context.*|NÃO bloquear .*/context.*" "context: memória ausente não bloqueia o comando"
assert_contains "$CONTEXT" "functional degraded mode|modo degradado funcional" "context: fallback ativa modo degradado funcional"
assert_contains "$CONTEXT" "DO NOT block .*/context.* because MCPs are unavailable|NÃO bloquear .*/context.* pela ausência de MCP" "context: MCP ausente não bloqueia o comando"
assert_contains "$CONTEXT" "DO NOT assume any specific MCP is required|NÃO assumir dependência obrigatória de nenhum MCP específico" "context: nenhum MCP específico é obrigatório"
assert_order "$CONTEXT" "Command activation rule|Regra de ativação do comando" "Common normative reference|Referência normativa comum" "context: regra de ativação vem antes da injeção normativa"
assert_contains "$WORKFLOW" "anti-compaction|ANTI-COMPACTION" "workflow: gate de invariantes anti-compaction presente"

BASE_PRECONDITIONS="${SRC_DIR}/_shared/base-preconditions.md"
assert_contains "$BASE_PRECONDITIONS" "Early activation rule|Regra de ativação antecipada" "base-preconditions: exceção antecipada para comando ativo"
assert_contains "$BASE_PRECONDITIONS" "DO NOT ask the user to run .*/context.*again|NÃO solicitar.*execute .*/context.*novamente" "base-preconditions: /context ativo não pede reexecução"

printf "\n=== Resultado ===\n"
printf "Total: %d passou, %d falhou\n" "$pass_count" "$fail_count"
if [[ "$fail_count" -gt 0 ]]; then
  exit 1
fi
