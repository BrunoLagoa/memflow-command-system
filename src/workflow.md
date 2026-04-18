---
name: context
description: Primeiro comando do fluxo — carrega e valida .agents, memória persistente (decisões e métricas) e MCPs. Utiliza memória como fonte primária e prepara contexto para decisões inteligentes no /workflow.
license: MIT
metadata:
  author: BrunoCastro
  version: "7.0.0"
---

## Carregar contexto

---

# Memória persistente (ALTA PRIORIDADE)

Se existir:

- .agents/memory/memory.md
- .agents/memory/session-memory.md
- .agents/memory/decisions.md
- .agents/memory/quality-metrics.md (NOVO)

---

## Uso da memória

Se memória estiver disponível:

### Fonte primária:

- memory.md → identidade do projeto
- decisions.md → decisões estratégicas

---

### Fonte secundária (NOVO):

- quality-metrics.md → desempenho do sistema

Uso:

- NÃO definir contexto base
- NÃO substituir decisões
- apenas enriquecer interpretação

---

## Regra de confiança da memória (CRÍTICO)

Se existirem:

- memory.md
- decisions.md

→ memória confiável

Observação:

- quality-metrics.md NÃO define confiabilidade
- atua apenas como complemento

---

# 🆕 Interpretação de métricas (preparação para workflow)

Se existir:
