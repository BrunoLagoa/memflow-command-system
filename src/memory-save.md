---
name: memory-save
description: Salva o estado da sessão e decisões relevantes — com detecção automática, score, versionamento, métricas, insights e sugestões de decisão.
license: MIT
metadata:
  author: BrunoCastro
  version: "10.0.0"
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
- `.agents/memory/decision-suggestions.md` (NOVO)

---

# Etapas 1–10

(mantidas exatamente como estão)

---

# 🆕 Etapa 11 — Registro de métricas

(mantida)

---

# 🆕 Etapa 12 — Geração de insights

(mantida da v9.1)

---

# 🆕 Etapa 13 — Sugestão de decisões (🔥 NOVO NÍVEL)

---

## Objetivo

Transformar padrões recorrentes em **sugestões estruturadas de decisão**, sem automatizar diretamente.

---

## Condições

Executar SOMENTE se:

- total_execuções ≥ 5  
- existe insight relevante  
- padrão consistente  

---

## Entrada

Utilizar:

- métricas  
- observações  
- histórico recente  

---

## Geração de sugestão

Para cada padrão identificado:

---

### Estrutura

```md
## Sugestão

Título: <nome curto>

Motivo:
<explicação baseada em métricas>

Recomendação:
<ação sugerida>

Impacto esperado:
<baixo | médio | alto>

Confiança:
<baixa | média | alta>