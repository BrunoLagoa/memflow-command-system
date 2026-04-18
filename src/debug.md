---
name: debug
description: Diagnóstico estruturado de bugs — classifica o erro (Simples/Estrutural/Crítico), lista causas por probabilidade e elege uma única causa mais provável com evidências. Não corrige. Integrado ao workflow e ao `model-policy.md` do target ativo (via `_shared/target-adapter.md`). Saída: Status, Análise, Problemas e Próximos passos. Próximo passo: /execute, /refactor ou /plan conforme classificação.
license: MIT
metadata:
  author: BrunoCastro
  version: "1.0.0"
---

## Referência normativa comum

Aplicar obrigatoriamente:

- `_shared/base-output.md`
- `_shared/base-preconditions.md`
- `_shared/base-degraded-mode.md`
- `_shared/target-adapter.md`

---

## Objetivo

Analisar profundamente um erro, bug ou comportamento inesperado:

- identificar causa raiz
- priorizar hipóteses
- orientar investigação
- preparar base para correção segura

---

## Integração com sistema

Este comando:

- NÃO executa correções
- NÃO substitui `/execute`
- NÃO decide fluxo

Ele prepara para:

→ `/execute` (correção)
→ `/refactor` (melhoria estrutural)
→ `/plan` (quando necessário)

---

## Uso de modelo (ALINHADO AO MODEL-POLICY)

Este comando deve:

- utilizar modelo intermediário ou avançado
- priorizar qualidade de diagnóstico

---

## Regras

1. Basear análise em:
   - `.agents`
   - `docs`
   - comportamento esperado do sistema

2. NÃO implementar correções

3. Após hipóteses:
   - escolher **uma única causa mais provável**

---

## Classificação do erro

Classificar o erro como:

- **Simples**
  - erro isolado
  - baixo impacto

- **Estrutural**
  - envolve arquitetura
  - múltiplos pontos

- **Crítico**
  - segurança
  - dados
  - fluxo do sistema

---

## Importante

- NÃO corrigir ainda
- NÃO pular investigação
- NÃO listar múltiplas causas sem priorizar
- Sempre indicar causa mais provável

---

## Formato obrigatório de saída

## Status

- Diagnóstico preliminar / Aguardando dados / Pronto para correção

---

## Análise

### Problema

- Descrição clara do erro

---

### Comportamento esperado

- Baseado em docs ou regras

---

### Classificação do erro

- Simples / Estrutural / Crítico

---

### Possíveis causas

- Lista ordenada por probabilidade

---

### Causa mais provável

- Apenas UMA
- Justificar com evidências
- Grau de confiança: baixa / média / alta
- O que confirmaria ou refutaria

---

### Análise técnica

- Onde está o problema:
  - arquivos
  - fluxo
  - lógica

---

### Impacto

- O que pode quebrar

---

### Plano de investigação

- Passos para validar
- Começar pela causa mais provável

---

## Problemas

- Dados insuficientes
- Incertezas
- Riscos de correção errada

Se não houver:
→ Nenhum

---

## Próximos passos

- Solicitar logs / repro (se necessário)
- Validar hipótese principal
- Após confirmação:
  → `/execute` (erro simples)
  → `/refactor` (erro estrutural)
  → `/plan` (erro complexo)
