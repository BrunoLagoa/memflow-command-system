---
name: memory-save
description: Salva o estado da sessão e decisões relevantes — com detecção automática, score, versionamento, métricas, insights, sugestões e controle de crescimento.
license: MIT
metadata:
  author: BrunoCastro
  version: "10.1.0"
---

## Referência normativa comum

Aplicar obrigatoriamente:

- `_shared/base-output.md`
- `_shared/base-preconditions.md`
- `_shared/base-degraded-mode.md`
- `_shared/target-adapter.md`

---

## Objetivo

Salvar o estado atual da sessão e preservar decisões importantes sem poluir a memória.

Gerenciar automaticamente:

- `.agents/memory/decisions.md`
- `.agents/memory/session-memory.md`
- `.agents/memory/quality-metrics.md`
- `.agents/memory/decision-suggestions.md`

---

# Etapas 1–10

(mantidas exatamente como estão)

---

# 🆕 Etapa 11 — Registro de métricas

(mantida)

---

# 🆕 Etapa 12 — Geração de insights

(mantida)

---

## 🆕 Controle de insights (CRÍTICO)

- máximo de 10 insights ativos
- se exceder:
  → remover os mais antigos  
  → manter os mais relevantes  

---

# 🆕 Etapa 13 — Sugestão de decisões

(mantida)

---

## 🆕 Controle de sugestões (CRÍTICO)

- máximo de 5 sugestões ativas  
- se exceder:
  → remover sugestões antigas  
  → priorizar maior confiança e impacto  

---

## 🆕 Deduplicação de sugestões

- NÃO permitir sugestões com mesmo título  
- se já existir:
  → atualizar sugestão existente  
  → NÃO criar nova  

---

# 🆕 Snapshot de métricas (NOVO)

Atualizar dentro de `quality-metrics.md`:

```md
## Snapshot atual

- Execuções: X
- Taxa aprovação: X%
- Taxa reprovação: X%
- Retrabalho médio: X
- Principal risco: <texto curto>
- Tendência: melhorando | estável | piorando