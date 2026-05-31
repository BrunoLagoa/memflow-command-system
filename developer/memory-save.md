---
name: memory-save
description: Salva o estado da sessão e decisões relevantes — com detecção automática, score, versionamento, dashboard de decisões, métricas, insights, sugestões e controle de crescimento. Integra resultados de /review e /review-code no ciclo de qualidade. Saída: Status (Salvo/Bloqueado/Não necessário), Análise, Problemas e Próximos passos.
license: MIT
metadata:
  author: BrunoCastro
  version: "11.2.0"
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

Gerenciar `.agents/memory/decisions.md` como **dashboard estruturado** — fonte de verdade das decisões persistentes com histórico rastreável.

Garantir que:

- decisões relevantes sobrevivam entre sessões
- scores reflitam uso real (reforço e obsolescência)
- métricas de qualidade alimentem `/context` e `/workflow` na próxima sessão
- `session-memory.md` funcione como estado temporário da sessão (não log) e seja limpo após persistência bem-sucedida

---

## Etapa 0 — Pré-condições (OBRIGATÓRIO)

Verificar:

1. `.agents/memory/` existe
   - Se NÃO → bloquear e orientar `/memory-init`
2. `.agents/memory/decisions.md` existe
   - Se `.agents/memory/` existe mas `decisions.md` NÃO → criar estrutura base (mesmo schema do `/memory-init`) e registrar na análise como fallback
   - Preferir `/memory-init` completo quando memória nunca foi inicializada
3. Invariantes anti-compaction válidos (pt-BR + Memflow)
   - Se NÃO → bloquear e orientar `/context`
4. Há conteúdo elegível para salvar (decisão, métrica ou sessão relevante)
   - Se NÃO → status `Não necessário` e parar

---

## Etapa 1 — Validação de relevância (OBRIGATÓRIA)

Executar somente se houver conteúdo relevante detectado em:

- output de `/execute` (score de relevância)
- output de `/review` ou `/review-code`
- `session-memory.md` (estado temporário da sessão)
- artefatos salvos (`.agents/docs/plans/`, `.agents/docs/brainstorm/`, etc.)

### NÃO salvar se for:

- logs técnicos ou output de debug
- execuções triviais (score < 21)
- repetições de informação já presente em `decisions.md`
- conteúdo temporário sem impacto futuro
- ações sem continuidade entre sessões
- sessão sem execução, review ou decisão detectável
- usuário escolher "Não salvar" no gate de confirmação

### SALVAR apenas se houver:

- decisões importantes
- mudanças relevantes
- definições técnicas ou arquiteturais
- contexto útil para continuidade futura
- métricas elegíveis após `/review` ou `/review-code`

### Regra de bloqueio

Se NÃO houver informação relevante:

- NÃO atualizar arquivos
- status `Não necessário` (não confundir com `Bloqueado`)
- em caso de dúvida sobre relevância → **NÃO salvar**

---

## Etapa 2 — Auto-detecção de decisões

Analisar a sessão atual e identificar automaticamente decisões.

### Indicadores de decisão

Detectar padrões como:

- "decidimos que…"
- "decidimos…"
- "vamos usar…"
- "não vamos mais usar…"
- "não usar mais…"
- "a partir de agora…"
- "padronizar…"
- "definido que…"
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

### Regras de cálculo

- somar **apenas** critérios aplicáveis à sessão
- limite máximo: **100**
- **não** duplicar critérios equivalentes (ex.: arquitetura + stack quando um já cobre o outro)
- garantir que toda decisão salva possua **Score** e **Impacto** coerentes (impacto é semântico, não derivado mecanicamente do score)

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

## Etapa 5 — Classificação de categoria

Mapear para seção em `decisions.md`:

| Tipo | Seção | Exemplos |
|------|-------|----------|
| Segurança, compliance, invariantes | `## Críticas` | stack, arquitetura, mudanças estruturais |
| Padrões, regras técnicas, implementação | `## Técnicas` | padrões de código, bibliotecas, contratos internos |
| Design, UX, acessibilidade | `## UI/UX` | interface, experiência, navegação |
| Demais | `## Outras` | fallback quando não couber acima |

Também registrar em `## Recentes` (máximo 5 entradas — ver Etapa 9).

Manter `decisions.md` organizado por categoria — não misturar tipos.

---

## Etapa 6 — Estrutura de `decisions.md`

Se `.agents/memory/decisions.md` não existir (fallback da Etapa 0), criar:

```md
# Decisões do Projeto

## Críticas
## Técnicas
## UI/UX
## Outras
## Recentes
## Histórico
```

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

## Etapa 10 — `session-memory.md` (durante e após a sessão)

### Durante a sessão (antes do save)

- `session-memory.md` é **estado temporário** — não é log, não é `decisions.md`
- NÃO transformar em histórico permanente
- manter entre **500–1000 tokens** quando houver conteúdo ativo
- se exceder 1000 tokens antes do save → condensar (remover redundâncias), **não** truncar decisões já detectadas
- registrar apenas contexto operacional da sessão corrente

### Após persistência bem-sucedida

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

Se o arquivo existir no formato legado (apenas `taxa_aprovacao:` soltos), migrar para a estrutura abaixo antes de incrementar contadores.

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

- máximo de **10** insights ativos em `quality-metrics.md` (seção `## Observações`)
- se exceder → aplicar eviction na ordem abaixo (remover o primeiro elegível):

### Critérios de eviction (insights)

Prioridade de **retenção** (manter os que pontuam melhor):

1. **Recência** — ocorrência nas últimas 5 sessões registradas em `## Execuções`
2. **Impacto em KPI** — insight ligado a reprovação ou retrabalho recente
3. **Frequência** — padrão com ≥ 3 ocorrências no histórico
4. **Data** — mais recente prevalece em empate

Remover primeiro o insight com **menor** pontuação nessa ordem. Registrar na análise quais insights foram removidos.

### Formato de insight em `## Observações`

```md
- [{tipo}] {descrição curta} (ocorrências: N, última: YYYY-MM-DD)
```

Exemplo:

```md
- [risco_alto_por_integracao] integrações externas reprovam com frequência (ocorrências: 4, última: 2026-05-28)
```

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
Ignoradas consecutivas: 0
Status: ativa
Data: YYYY-MM-DD
```

### Controle de sugestões (CRÍTICO)

- máximo de **5** sugestões com `Status: ativa`
- se exceder → aplicar eviction (ver critérios abaixo)

### Critérios de eviction (sugestões)

Prioridade de **retenção** (manter as que pontuam melhor):

1. **Confiança** — alta > média > baixa
2. **Impacto esperado** — alto > médio > baixo
3. **Recência** — `Data` mais recente
4. **Menos ignoradas** — menor `Ignoradas consecutivas`

Remover primeiro a sugestão com **menor** pontuação nessa ordem. Registrar na análise.

### Expiração de sugestões ignoradas

- quando o usuário **ignorar** via `/workflow` → incrementar `Ignoradas consecutivas` em +1
- quando o usuário **aplicar** → remover sugestão da lista ativa
- se `Ignoradas consecutivas` ≥ **3** → arquivar:
  - alterar `Status: arquivada`
  - mover para seção `## Arquivadas` no final de `decision-suggestions.md`
  - NÃO reapresentar em `/workflow` salvo regeneração com novo insight

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
5. NÃO transformar `session-memory.md` em log permanente
6. NÃO aplicar sugestões automaticamente
7. NÃO decidir estratégia de execução
8. Em caso de dúvida sobre relevância ou conflito → **NÃO salvar**

---

## Boas práticas

- usar ao final de cada tarefa relevante (especialmente após `/review`)
- evitar uso em tarefas triviais
- priorizar qualidade sobre quantidade de entradas
- `.agents/memory/decisions.md` é a fonte de verdade — score deve refletir importância real

---

## Formato obrigatório de saída

## Status

- Salvo
- Bloqueado
- Não necessário
- Parcial

---

## Análise

### Validação

- Conteúdo relevante identificado: SIM / NÃO
- Decisões detectadas: SIM / NÃO
- Score calculado: X/100
- Impacto: Baixo | Médio | Alto
- Categoria atribuída: Críticas | Técnicas | UI/UX | Outras
- Tipo de ação: Nova decisão | Reforço | Atualização | Métricas | Sessão
- Justificativa: (breve)

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

- Informação irrelevante (se `Não necessário`)
- Ambiguidades na classificação ou detecção
- Possível conflito com decisões existentes
- Limitações de detecção automática
- Bootstrap ausente ou incompleto

Se não houver:
→ Nenhum

---

## Próximos passos

Se `Não necessário` ou `Bloqueado`:

- Nenhuma ação de persistência necessária

Se `Salvo`:

- `/context` — recarregar memória atualizada
- Dashboard de decisões atualizado em `decisions.md`
- Continuar fluxo SDLC conforme `/workflow`
- Revisar sugestões pendentes em `decision-suggestions.md` (se geradas)
