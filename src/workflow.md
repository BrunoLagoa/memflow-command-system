---
name: workflow
description: Orquestrador central — decide execução, validação e adapta comportamento com base em decisões, métricas, insights e sugestões assistidas.
license: MIT
metadata:
  author: BrunoCastro
  version: "8.0.0"
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
- decision-suggestions.md (NOVO)
- model-policy

---

# Etapa 0 — Decisões existentes

(mantido)

---

# Etapa 0.5 — Métricas

(mantido)

---

# Etapa 0.6 — Insights

(mantido)

---

# 🆕 Etapa 0.7 — Decision Suggestions (🔥 NOVO)

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

Ativar SOMENTE se:

- confiança = média ou alta  
- impacto = médio ou alto  

---

## Modo assistido

NÃO aplicar automaticamente

---

## Resultado

Adicionar no output:

```md
## Sugestões relevantes

- <título>
- recomendação: <texto>
- ação sugerida: aplicar / ignorar