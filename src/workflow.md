---
name: workflow
description: Orquestrador central — decide execução, validação e adapta comportamento com base em decisões, métricas, insights e sugestões assistidas, com controle de previsibilidade e evolução. É a única fonte de decisão de estratégia para /execute.
license: MIT
metadata:
  author: BrunoCastro
  version: "9.5.0"
---

## Referência normativa comum

Aplicar obrigatoriamente:

- `_shared/base-output.md`
- `_shared/base-preconditions.md`
- `_shared/base-degraded-mode.md`
- `_shared/target-adapter.md`
- `model-policy.md`

---

## Objetivo

Decidir:

- execução (/execute ou /plan)
- validação (/review, /review-code)
- modelo
- adaptação inteligente baseada em histórico

---

## Base de decisão

- decisions.md
- quality-metrics.md
- decision-suggestions.md
- skills disponíveis no projeto (quando existirem)
- model-policy

---

# 🆕 Prioridade de decisão (CRÍTICO)

Ordem obrigatória:

1. **decisions.md (sempre prevalece)**
2. **skills aplicáveis (quando existirem)**
3. **regras do workflow**
4. **insights (ajuste leve)**
5. **decision-suggestions (modo assistido)**

---

## Regras

- decisões explícitas NUNCA podem ser sobrescritas  
- skills disponíveis e aplicáveis NÃO podem ser ignoradas
- insights apenas ajustam comportamento  
- sugestões NUNCA executam automaticamente  
- em caso de conflito → respeitar ordem acima  
- `/workflow` é a única origem de decisão de estratégia (`/execute` vs `/plan`)
- NÃO prosseguir sem invariantes anti-compaction validados pelo `/context`

---

# Etapa 0 — Decisões existentes

- verificar decisões anteriores  
- priorizar por score  
- detectar conflitos  

---

# Etapa 0.5 — Métricas

Se existir:

- taxa aprovação  
- taxa reprovação  
- retrabalho médio  

---

# Etapa 0.6 — Insights

Detectar:

- baixa clareza  
- alta complexidade  
- integrações externas  
- alto retrabalho  

---

# Etapa 0.7 — Decision Suggestions

Se existir:

.agents/memory/decision-suggestions.md

---

## Analisar sugestões

Para cada sugestão:

- título  
- recomendação  
- impacto  
- confiança  

---

## Critérios de ativação

- confiança ≥ média  
- impacto ≥ médio  

---

## 🆕 Limite de uso (CRÍTICO)

- aplicar limite dinâmico por execução:
  - baixa complexidade e baixo risco: no máximo **2 sugestões**
  - média complexidade ou risco médio: no máximo **3 sugestões**
  - alta complexidade ou alto risco: no máximo **4 sugestões**
- quando houver mais sugestões elegíveis que o limite, priorizar por:
  - maior impacto
  - maior confiança

---

## Modo assistido

- NÃO aplicar automaticamente  
- apenas sugerir  

---

# Etapa 0.8 — Skills do projeto (OBRIGATÓRIO)

Se o `/context` indicar skills disponíveis no projeto:

- identificar skills relevantes para a tarefa atual
- registrar quais skills devem ser usadas antes da continuidade
- orientar uso explícito das skills aplicáveis

Se houver skill claramente aplicável:

- NÃO avançar para execução direta sem orientar uso da skill

Se a aplicabilidade estiver ambígua:

- solicitar confirmação objetiva ao usuário antes de seguir

---

# Etapa 0.9 — Gate de invariantes anti-compaction (OBRIGATÓRIO)

Validar se o `/context` confirmou invariantes:

- idioma pt-BR validado
- identidade Memflow validada

Se status vier como `Reidratados`:

- permitir continuidade normal
- registrar no output que houve recuperação pós-compaction

Se status vier como `Falhou` ou ausente:

- BLOQUEAR decisão do workflow
- exigir nova execução de `/context`

---

# 🆕 Aplicação de sugestão (INLINE 🔥)

Quando uma sugestão for apresentada:

### O usuário pode decidir:

- **aplicar**
- **ignorar**

---

## Se aplicar:

- converter recomendação em decisão  
- registrar em `decisions.md`  
- remover da lista de sugestões  
- registrar via `/memory-save`  

---

## Se ignorar:

- manter sugestão (ou permitir expiração natural)  

---

## Importante

- aplicação deve ser explícita  
- nunca automática  
- deve gerar rastreabilidade  

---

## Resultado

Adicionar no output:

## Sugestões relevantes

- título: <nome>
- recomendação: <texto>
- ação disponível:
  - aplicar
  - ignorar  

---

# Etapa 1 — Classificação da tarefa

- Complexidade: baixa / média / alta  
- Impacto: baixo / médio / alto  
- Risco: baixo / médio / alto  
- Clareza: alta / média / baixa  

---

# Etapa 2 — Decisão de execução

---

## EXECUÇÃO DIRETA

- baixa complexidade  
- baixo risco  
- alta clareza  

---

## EXECUÇÃO COM /plan

- média/alta complexidade  
- risco médio/alto  
- baixa clareza  

---

## Ajuste por insights

- baixa clareza → FORÇAR /plan  
- alta complexidade → priorizar /plan  
- retrabalho alto → evitar execução direta  

---

# Etapa 3 — Estratégia de validação

---

## /review

- SEMPRE obrigatório  

---

## /review-code

Obrigatório quando:

- código modificado  
- risco ≥ médio  
- integração externa  
- mudança arquitetural  
- sugestão indicar risco técnico  

---

## Ajuste por insights

- integração externa → FORÇAR /review-code  
- histórico de erro alto → reforçar validação  

---

# Etapa 4 — Gate de qualidade

---

## BLOQUEAR

- review = Reprovado  
- review-code = Reprovado  

---

## PERMITIR COM RESSALVAS

- qualquer “com ressalvas”  

---

## APROVAR

- ambos aprovados  

---

# Etapa 5 — Orquestração de modelo

- modelo econômico por padrão  
- escalar quando necessário  

---

# Etapa 6 — Controle de consistência

- NÃO ignorar decisões  
- NÃO ignorar métricas  
- NÃO ignorar insights  
- NÃO ignorar sugestões  
- NÃO ignorar skills aplicáveis
- limitar influência de sugestões  

---

# Integração

- /execute  
- /review  
- /review-code  
- /memory-save  

---

# Regras

- NÃO implementar  
- NÃO permitir bypass  
- NÃO ignorar risco  
- exigir retorno ao `/workflow` se decisão estiver ausente

---

# Importante

- decisões são soberanas  
- insights ajustam  
- sugestões orientam  
- sistema deve permanecer previsível  

---

# Formato de saída

## Status

- Decisão tomada  

---

## Análise

### Classificação

- Complexidade:
- Impacto:
- Risco:
- Clareza:

---

### Métricas

- disponíveis: SIM / NÃO  
- taxa_reprovação:

---

### Insights

- sinais detectados:

---

### Sugestões

- lista de sugestões relevantes  
- ações disponíveis: aplicar / ignorar  

---

### Skills

- disponíveis no projeto: SIM / NÃO
- skills aplicáveis para a tarefa:
- ação: usar skill agora / não aplicável (justificar)

---

### Invariantes anti-compaction

- idioma pt-BR: OK / Falhou
- identidade Memflow: OK / Falhou
- re-hidratação necessária: SIM / NÃO

---

### Estratégia

- Execução: Direta / Planejada  
- Validação:

---

## Problemas

- ambiguidades  
- riscos  
- falha de invariantes anti-compaction (quando houver)

Se não houver:
→ Nenhum  

---

## Próximos passos

1. /execute ou /plan  
2. /review  
3. /review-code  
4. /memory-save  
5. Se houver skill aplicável: usar a skill antes de continuar
6. Se invariantes anti-compaction falharem: reexecutar `/context`