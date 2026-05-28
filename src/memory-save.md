---
name: memory-save
description: Salva o estado da sessão e decisões relevantes — com detecção automática, score, versionamento, métricas, insights, sugestões e controle de crescimento. Integra resultados de /review e /review-code no ciclo de qualidade. Saída: Status (Salvo/Bloqueado/Não necessário), Análise, Problemas e Próximos passos.
license: MIT
metadata:
  author: BrunoCastro
  version: "11.0.0"
---

## Referência normativa comum

Aplicar obrigatoriamente:

- `_shared/base-output.md`
- `_shared/base-preconditions.md`
- `_shared/base-degraded-mode.md`
- `_shared/target-adapter.md`
- `model-policy.md`

---

## Integração com sistema (CRÍTICO)

Este comando:

- DEVE ser usado quando `/execute` recomendar (score ≥ 51) ou após `/review` / `/review-code`
- PODE ser invocado manualmente pelo usuário a qualquer momento
- NÃO decide estratégia de execução (isso é `/workflow`)
- NÃO implementa código
- NÃO sobrescreve decisões em `decisions.md` sem confirmação explícita

Arquivos gerenciados:

- `.agents/memory/decisions.md`
- `.agents/memory/session-memory.md`
- `.agents/memory/quality-metrics.md`
- `.agents/memory/decision-suggestions.md`

---

## Objetivo

Salvar o estado atual da sessão e preservar decisões importantes **sem poluir a memória**.

Garantir que:

- decisões relevantes sobrevivam entre sessões
- scores reflitam uso real (reforço e obsolescência)
- métricas de qualidade alimentem `/context` e `/workflow` na próxima sessão
- `session-memory.md` seja limpo após persistência bem-sucedida

---

## Etapa 0 — Pré-condições (OBRIGATÓRIO)

Verificar:

1. `.agents/memory/` existe
   - Se NÃO → bloquear e orientar `/memory-init`
2. Invariantes anti-compaction válidos (pt-BR + Memflow)
   - Se NÃO → bloquear e orientar `/context`
3. Há conteúdo elegível para salvar (decisão, métrica ou sessão relevante)
   - Se NÃO → status `Não necessário` e parar

---

## Etapa 1 — Validação de relevância

Executar somente se houver conteúdo relevante detectado em:

- output de `/execute` (score de relevância)
- output de `/review` ou `/review-code`
- `session-memory.md` (estado temporário da sessão)
- artefatos salvos (`.agents/docs/plans/`, `.agents/docs/brainstorm/`, etc.)

### Não salvar quando:

- score de relevância < 21 (ajuste trivial, sem decisão)
- sessão sem execução, review ou decisão detectável
- usuário escolher "Não salvar" no gate de confirmação

---

## Etapa 2 — Detecção de decisões

Analisar a sessão atual e detectar padrões como:

- "vamos usar…"
- "decidimos…"
- "padronizar…"
- "não usar mais…"
- decisões explícitas em `/brainstorm`, `/plan`, `/spec` ou `/prd` salvos
- reforço de decisão existente (mesmo tema, evidência adicional)

Para cada candidato, extrair:

- **título/slug** (kebab-case, único)
- **texto da decisão** (1–3 frases objetivas)
- **contexto** (por que foi tomada)
- **categoria** (Crítica | Técnica | UI/UX | Outra)

---

## Etapa 3 — Score de relevância (0–100)

Alinhado ao `/execute`:

| Critério | Pontos |
|----------|--------|
| Mudança de stack | +40 |
| Decisão arquitetural | +30 |
| Padrão global | +20 |
| Impacto múltiplos arquivos | +10 |
| Mudança local | +5 |
| Ajuste trivial | 0 |

### Interpretação

- **0–20** → Não salvar
- **21–50** → Pode salvar (confirmar com usuário)
- **51–80** → Recomendar salvar
- **81–100** → Recomendar fortemente

---

## Etapa 4 — Determinação de impacto

Classificar cada decisão:

- **Baixo** — escopo local, reversível, sem efeito sistêmico
- **Médio** — afeta módulo ou fluxo relevante
- **Alto** — arquitetura, segurança, contrato público ou múltiplos domínios

---

## Etapa 5 — Classificação

Mapear para seção em `decisions.md`:

| Tipo | Seção |
|------|-------|
| Segurança, compliance, invariantes | `## Críticas` |
| Stack, arquitetura, padrões de código | `## Técnicas` |
| Design, UX, acessibilidade | `## UI/UX` |
| Demais | `## Outras` |

Também registrar em `## Recentes` (máximo 5 entradas — ver Etapa 9).

---

## Etapa 6 — Estrutura de `decisions.md`

### Schema obrigatório por decisão

```md
### {slug} (score: N)
- Categoria: Crítica | Técnica | UI/UX | Outra
- Impacto: Baixo | Médio | Alto
- Decisão: <texto objetivo>
- Contexto: <por que foi tomada>
- Data: YYYY-MM-DD
- Versão: 1
```

### Regras de slug

- kebab-case (`dark-mode-strategy`, `email-normalization`)
- único no arquivo
- estável entre sessões (não renomear sem motivo)

---

## Etapa 7 — Versionamento e lifecycle de score

Antes de escrever, comparar cada candidato com `decisions.md` existente.

### Nova decisão

- criar entrada com score calculado na Etapa 3
- `Versão: 1`

### Reforço (mesmo tema, evidência adicional ou uso bem-sucedido)

- **não** criar duplicata
- atualizar `Decisão` e `Contexto` se houver informação nova
- score: **+5** (máximo 100)
- incrementar `Versão`

### Contradição (decisão anterior violada ou revertida)

- adicionar nota em `Contexto` com data e motivo
- score: **−15** (mínimo 0)
- se score < 30 → mover para seção `## Histórico` com nota de obsolescência

### Duplicata exata

- mesclar em entrada existente
- **não** criar nova

---

## Etapa 8 — Confirmação obrigatória antes de escrever (CRÍTICO)

Antes de alterar qualquer arquivo, apresentar resumo e solicitar confirmação:

```
Resumo do que será salvo:

Decisões:
- {slug} (score: N, {nova|reforço|atualização})
- ...

Métricas: {sim|não}
Session-memory: será limpo após salvar

Deseja persistir?

A) Sim, salvar tudo
B) Salvar apenas decisões (sem métricas)
C) Não salvar
```

- **A** → prosseguir com Etapas 9–13
- **B** → pular Etapa 11 (métricas), executar demais
- **C** → status `Não necessário` e parar

NÃO escrever arquivos sem confirmação explícita.

---

## Etapa 9 — Escrita das decisões e recentes

1. Inserir ou atualizar entradas nas seções corretas (`Críticas`, `Técnicas`, `UI/UX`, `Outras`)
2. Atualizar `## Recentes`:
   - adicionar slug + data no topo
   - manter **máximo 5** entradas
   - remover a mais antiga se exceder

---

## Etapa 10 — Limpeza de `session-memory.md`

Após persistência bem-sucedida:

- limpar conteúdo operacional temporário de `session-memory.md`
- manter placeholder mínimo ou arquivo vazio
- registrar na análise: `Session-memory limpo: SIM`

Se persistência falhar ou usuário cancelar → **não** limpar.

---

## Etapa 11 — Registro de métricas

### Condições

Registrar SOMENTE se:

- houve `/review` ou `/review-code` nesta sessão
- execução não foi trivial

### Dados coletados

- `review_result`: aprovado | aprovado_com_ressalvas | reprovado
- `review_code_result`: aprovado | aprovado_com_ressalvas | reprovado
- `retrabalho`: sim | não
- `complexidade`: baixa | média | alta

### Atualização de `quality-metrics.md`

Incrementar contadores e recalcular KPIs:

```md
# Métricas de Qualidade

## Execuções

- total: N
- aprovadas: N
- aprovadas_com_ressalvas: N
- reprovadas: N

## KPIs

- taxa_aprovacao: N%
- taxa_reprovacao: N%
- retrabalho_medio: N

## Snapshot atual

- Execuções: N
- Taxa aprovação: N%
- Taxa reprovação: N%
- Retrabalho médio: N
- Principal risco: <texto curto>
- Tendência: melhorando | estável | piorando

## Observações

- (insights gerados na Etapa 12)
```

### Efeito na próxima sessão

- `/context` classifica qualidade (alta | média | baixa)
- `/workflow` pode exigir `/plan` ou validação reforçada quando qualidade baixa

---

## Etapa 12 — Geração de insights

Analisar padrões em métricas e observações recentes.

### Condições

Gerar insight SOMENTE se:

- total de execuções ≥ 3
- padrão consistente (≥ 2 ocorrências similares)

### Tipos de insight

- `risco_alto_por_clareza` — tasks com baixa clareza falham mais
- `risco_alto_por_integracao` — integrações externas têm alto erro
- `necessidade_de_planejamento` — execuções diretas reprovam com frequência
- `necessidade_de_validacao_reforcada` — reprovações em áreas específicas

### Controle de insights (CRÍTICO)

- máximo de **10** insights ativos em `quality-metrics.md`
- se exceder → remover os mais antigos, manter os mais relevantes

---

## Etapa 13 — Sugestão de decisões

Transformar padrões recorrentes em **sugestões estruturadas**, sem automatizar.

### Condições

Executar SOMENTE se:

- total_execuções ≥ 5
- existe insight relevante da Etapa 12
- padrão consistente identificado

### Estrutura em `decision-suggestions.md`

```md
## Sugestão: {título}

Motivo:
<explicação baseada em métricas>

Recomendação:
<ação sugerida>

Impacto esperado: baixo | médio | alto
Confiança: baixa | média | alta
Data: YYYY-MM-DD
```

### Controle de sugestões (CRÍTICO)

- máximo de **5** sugestões ativas
- se exceder → remover antigas, priorizar maior confiança e impacto

### Deduplicação de sugestões

- NÃO permitir sugestões com mesmo título
- se já existir → atualizar existente, NÃO criar nova

### Integração com `/workflow`

- sugestões são **modo assistido** — nunca aplicadas automaticamente
- usuário decide aplicar ou ignorar via `/workflow`
- se aplicar → converter em decisão e registrar via `/memory-save`

---

## Uso de modelo (ALINHADO AO MODEL-POLICY)

- Detecção e classificação de decisões → modelo econômico
- Geração de insights e sugestões → modelo intermediário quando histórico ≥ 5 execuções
- Escalar apenas se ambiguidade alta na classificação

---

## Regras obrigatórias

1. NÃO salvar sem confirmação explícita
2. NÃO duplicar decisões (mesclar ou reforçar)
3. NÃO poluir memória com ajustes triviais (score < 21)
4. NÃO limpar `session-memory.md` se persistência falhou
5. NÃO aplicar sugestões automaticamente
6. NÃO decidir estratégia de execução

---

## Formato obrigatório de saída

## Status

- Salvo
- Bloqueado
- Não necessário
- Parcial

---

## Análise

### Persistência

- Decisões salvas: N (lista de slugs)
- Decisões reforçadas: N
- Decisões arquivadas: N
- Métricas atualizadas: SIM / NÃO / N/A
- Insights gerados: N
- Sugestões geradas: N
- Session-memory limpo: SIM / NÃO

### Score da sessão

- Score de relevância: X/100
- Recomendação original do `/execute`: (se aplicável)

### Arquivos alterados

- `.agents/memory/decisions.md`
- `.agents/memory/quality-metrics.md`
- `.agents/memory/decision-suggestions.md`
- `.agents/memory/session-memory.md`

---

## Problemas

- Conflitos detectados
- Decisões ambíguas não salvas
- Bootstrap ausente

Se não houver:
→ Nenhum

---

## Próximos passos

- `/context` — recarregar memória atualizada
- Continuar fluxo SDLC conforme `/workflow`
- Revisar sugestões pendentes em `decision-suggestions.md` (se geradas)
