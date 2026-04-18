---
name: memory-save
description: Salva o estado da sessão e decisões relevantes — com detecção automática, score, versionamento, métricas de qualidade e geração de insights automáticos.
license: MIT
metadata:
  author: BrunoCastro
  version: "9.1.0"
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

---

# Etapa 1 — Validação de relevância

Executar somente se houver conteúdo relevante.

---

# Etapa 2 — Detecção de decisões

Detectar padrões como:

- “vamos usar…”
- “decidimos…”
- “padronizar…”
- “não usar mais…”

---

# Etapa 3 — Score de relevância (0–100)

- Mudança de stack: +40  
- Decisão arquitetural: +30  
- Padrão global: +20  
- Impacto múltiplos arquivos: +10  
- Mudança local: +5  

---

# Etapa 4 — Determinação de impacto

- baixo / médio / alto

---

# Etapa 5 — Classificação

- técnica / arquitetura / padrão / sessão

---

# Etapa 6 — Estrutura decisions.md

(mantido)

---

# Etapa 7 — Versionamento

(mantido)

---

# Etapa 8 — Escrita das decisões

(mantido)

---

# Etapa 9 — Atualização de recentes

(mantido)

---

# Etapa 10 — Escrita final

(mantido)

---

# 🆕 Etapa 11 — Registro de métricas

## Condições

Registrar SOMENTE se:

- houve `/review` ou `/review-code`
- execução não trivial

---

## Dados coletados

- review_result: aprovado | aprovado_com_ressalvas | reprovado  
- review_code_result: aprovado | aprovado_com_ressalvas | reprovado  
- retrabalho: sim | não  
- complexidade: baixa | média | alta  

---

## Estrutura do arquivo

Criar ou atualizar:

.agents/memory/quality-metrics.md

---

## Estrutura base

```md
# Quality Metrics

## Execuções

- total: 0
- aprovadas: 0
- aprovadas_com_ressalvas: 0
- reprovadas: 0

## KPIs

- taxa_aprovacao: 0%
- taxa_reprovacao: 0%
- retrabalho_medio: 0

## Observações

- (insights gerados automaticamente)