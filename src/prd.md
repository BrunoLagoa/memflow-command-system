---
name: prd
description: Transforma ideia ou problema em PRD com 8 seções (contexto, objetivo, persona, escopo, regras de negócio, fluxo funcional, critérios de aceite, riscos). Entrada: ideia + contexto + objetivo desejado. Base do sistema — alimenta /spec → /plan → /execute. Não implementa. Bloqueia se faltar informação ou houver ambiguidade.
license: MIT
metadata:
  author: BrunoCastro
  version: "1.0.0"
---

## Referência normativa comum

Aplicar obrigatoriamente `~/.config/opencode/commands/memflow/_shared/base-output.md` (global) ou `.opencode/commands/memflow/_shared/base-output.md` (local).
Aplicar obrigatoriamente `~/.config/opencode/commands/memflow/_shared/base-preconditions.md` (global) ou `.opencode/commands/memflow/_shared/base-preconditions.md` (local).
Aplicar obrigatoriamente `~/.config/opencode/commands/memflow/_shared/base-degraded-mode.md` (global) ou `.opencode/commands/memflow/_shared/base-degraded-mode.md` (local).

---

## Objetivo

Transformar uma ideia ou problema em um PRD:

- claro
- completo
- sem ambiguidades
- pronto para alimentar `/spec` e `/plan`

---

## Integração com sistema

Este comando:

- é a base do sistema
- alimenta `/spec` → `/plan` → `/execute`
- influencia decisões do `/workflow`

---

## Uso de modelo (ALINHADO AO MODEL-POLICY)

Este comando deve:

- utilizar modelo intermediário ou superior
- priorizar clareza e definição correta do problema

---

## Entrada esperada

O usuário deve fornecer:

- ideia / problema
- contexto
- objetivo desejado

Se incompleto:
→ solicitar mais informações antes de continuar

---

## Estrutura do PRD

### 1. Contexto

- Problema que está sendo resolvido
- Por que é importante

---

### 2. Objetivo

- Resultado esperado
- Métrica de sucesso (se possível)

---

### 3. Usuário / Persona

- Quem será impactado
- Dor atual

---

### 4. Escopo

#### Inclui:

- Lista clara do que será feito

#### Não inclui:

- O que está fora do escopo

---

### 5. Regras de negócio

- Regras obrigatórias
- Restrições
- Comportamentos esperados

---

### 6. Fluxo funcional

- Passo a passo da interação do usuário
- Comportamento do sistema

---

### 7. Critérios de aceite

- Como validar sucesso
- Casos positivos
- Casos de erro

---

### 8. Riscos e dúvidas

- Pontos indefinidos
- Dependências externas
- Possíveis conflitos

---

## Integração com `/spec` (CRÍTICO)

- Este PRD deve permitir criação de `/spec` sem suposições
- Se o `/spec` precisar assumir algo → PRD está incompleto

---

## Validação obrigatória

Antes de finalizar, responder:

- PRD está completo: SIM / NÃO
- Existem dúvidas abertas: (listar)
- Conflito com `.agents`: SIM / NÃO
- Conflito com `docs`: SIM / NÃO

---

## Regras de bloqueio

- Se houver ambiguidade → PARAR
- Se faltar informação → PARAR
- Se houver conflito com `.agents` → PARAR

---

## Formato obrigatório de saída

## Status

- PRD criado / Bloqueado

---

## Análise

### Clareza do problema

- bem definido / parcial / indefinido

---

### Qualidade do PRD

- completo / incompleto

---

### Pronto para especificação

- SIM / NÃO

---

## Problemas

- ambiguidades
- lacunas
- inconsistências

Se não houver:
→ Nenhum

---

## Próximos passos

Se completo:

- Seguir para `/spec`

Se incompleto:

- Ajustar PRD
- Solicitar mais informações

---

## Importante

- NÃO implementar
- NÃO gerar código
- NÃO assumir comportamento
- Este comando define a base de todo o sistema
