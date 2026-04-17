---
name: spec
description: Transforma PRD ou descrição em especificação técnica com 8 seções (objetivo, tecnologia, design, funcionalidades, fluxos, inputs, outputs, modelo de dados). Entrada: /prd ou descrição direta. Base para /plan — se o /plan precisar assumir algo, a spec está incompleta. Não implementa. Bloqueia se houver ambiguidade. Próximo passo: /plan.
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

Transformar um PRD ou ideia em uma especificação técnica:

- clara
- objetiva
- sem ambiguidades
- pronta para ser usada pelo `/plan`

---

## Integração com sistema

Este comando:

- recebe entrada de `/prd` ou descrição direta
- serve como base para `/plan`
- NÃO executa
- NÃO decide fluxo

---

## Uso de modelo (ALINHADO AO MODEL-POLICY)

Este comando deve:

- utilizar modelo intermediário
- priorizar clareza e precisão técnica

---

## Diretrizes

- Escrever apenas o necessário para implementação
- Evitar contexto irrelevante
- Não incluir:
  - métricas de negócio
  - storytelling
  - conteúdo não técnico

---

## Entrada esperada

- PRD
  ou
- descrição da feature

---

## Estrutura obrigatória

### Objetivo

- O que deve ser construído

---

### Tecnologia

- Stack obrigatória
- Integrações (ex: APIs, Supabase)
- Bibliotecas padrão

---

### Design

- Design system
- Regras visuais
- padrões de UI existentes

---

### Funcionalidades

- Lista clara e objetiva
- comportamentos esperados
- interações do usuário

---

### Fluxos principais

1. Ação do usuário
2. Resposta do sistema
3. Resultado esperado

---

### Inputs

- Dados de entrada
- Origem (user, API, form)

---

### Outputs

- Dados retornados
- UI esperada
- efeitos colaterais

---

### Modelo de dados (se aplicável)

Para cada entidade:

- nome
- campos
- tipo
- validações

---

### Casos extremos

- erros possíveis
- inputs inválidos
- estados vazios

---

## Integração com `/plan` (CRÍTICO)

- Esta especificação deve permitir criação de plano sem suposições
- Se o `/plan` precisar assumir algo → spec está incompleta

---

## Validação obrigatória

Antes de finalizar, responder:

- Especificação completa: SIM / NÃO
- Ambiguidades: (listar)
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

- Especificação criada / Bloqueado

---

## Análise

### Estrutura da solução

- visão geral técnica

---

### Clareza da especificação

- completa / incompleta

---

### Pronto para planejamento

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

- Seguir para `/plan`

Se incompleto:

- Ajustar especificação
- Solicitar informações

---

## Importante

- NÃO implementar
- NÃO gerar código
- NÃO assumir comportamento
- Este comando define base técnica para o plano
