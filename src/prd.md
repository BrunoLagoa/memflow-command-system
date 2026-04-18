---
name: prd
description: Transforma ideia ou problema em um PRD estruturado, mensurável e pronto para execução. Inclui definição estratégica, experiência do usuário, requisitos técnicos e critérios de validação. Base do sistema — alimenta /spec → /plan → /execute. Não implementa. Em ambiguidade ou trade-off, pode apresentar opções e bloqueia até decisão do usuário. Bloqueia se faltar informação ou houver ambiguidade não resolvida.
license: MIT
metadata:
  author: BrunoCastro
  version: "2.1.0"
---

## Referência normativa comum

Aplicar obrigatoriamente:

- `_shared/base-output.md`
- `_shared/base-preconditions.md`
- `_shared/base-degraded-mode.md`
- `_shared/target-adapter.md`

---

## Objetivo

Transformar uma ideia ou problema em um PRD:

- claro
- completo
- mensurável
- sem ambiguidades
- pronto para alimentar `/spec` e `/plan`
- utilizável como fonte única de verdade

---

## Integração com sistema

Este comando:

- é a base do sistema
- alimenta `/spec` → `/plan` → `/execute`
- influencia decisões do `/workflow`
- define escopo e limites do sistema

---

## Uso de modelo (ALINHADO AO MODEL-POLICY)

Este comando deve:

- utilizar modelo intermediário ou superior
- priorizar precisão sobre velocidade
- evitar inferências não validadas

---

## Entrada esperada

O usuário deve fornecer:

- ideia / problema
- contexto
- objetivo desejado

Se incompleto:
→ solicitar mais informações antes de continuar (OBRIGATÓRIO)

---

## Fase obrigatória: Discovery (ANTES DE GERAR PRD)

Antes de gerar o PRD, validar:

- Qual problema real está sendo resolvido?
- Por que isso é importante agora?
- Como o sucesso será medido?
- Existem restrições técnicas ou de negócio?

Se qualquer resposta estiver indefinida:
→ BLOQUEAR geração do PRD

### Ambiguidade, trade-offs e escolha do usuário

Quando houver **mais de uma interpretação válida**, **trade-off relevante** entre alternativas ou **conflito de escopo/comportamento** ainda não decidido pelo usuário:

- **Não** escolher sozinho a direção de produto, escopo ou comportamento esperado.
- Apresentar **2 a 4 opções** com prós e contras breves; pode incluir **recomendação fundamentada**, sem substituir a decisão do usuário.
- **BLOQUEAR** a geração (ou continuação) do PRD até o usuário **escolher uma opção** ou **definir critério decisório** explícito.

---

# Estrutura do PRD

---

## 1. Executive Summary

### Problem Statement
- Descrição objetiva do problema (1–2 frases)

### Proposed Solution
- Descrição objetiva da solução (1–2 frases)

### Success Criteria (KPIs obrigatórios)
- Métricas mensuráveis
- Devem conter valor numérico + condição

Exemplo:
- Tempo de resposta < 200ms em 95% dos casos
- Taxa de sucesso ≥ 90%

---

## 2. Contexto

- Cenário atual
- Impacto do problema
- Por que resolver isso agora

---

## 3. Objetivo

- Resultado esperado
- KPIs obrigatórios (não opcional)

---

## 4. Usuário e Experiência

### Personas
- Quem será impactado
- Dor atual

### User Stories (OBRIGATÓRIO)
Formato:
> As a [user], I want to [action] so that [benefit]

### Critérios de aceite por história (OBRIGATÓRIO)

**Escopo:** cada User Story acima.

- O que precisa ser verdadeiro para **aquela história** estar pronta (incluir referência à história).
- Casos positivos e negativos **no recorte da história** (comportamento, dados, permissões).
- **Não** repetir aqui a validação global da entrega ou do incremento — isso fica na seção **11** (nível PRD / release).

---

## 5. Escopo

### Inclui
- Lista clara do que será feito

### Non-Goals (OBRIGATÓRIO)
- O que NÃO será feito nesta fase
- Decisões conscientes de exclusão

---

## 6. Regras de negócio

- Regras obrigatórias
- Restrições
- Comportamentos esperados

---

## 7. AI Requirements (Se aplicável)

### Modelos e ferramentas
- LLMs utilizados
- APIs externas
- Ferramentas auxiliares

### Estratégia de fallback
- O que acontece em falhas

---

## 8. Estratégia de Avaliação

- Como validar qualidade
- Benchmarks
- Métricas de precisão
- Testes obrigatórios

Exemplo:
- ≥ 85% precisão
- ≤ 5% inconsistência

---

## 9. Especificação Técnica

### Arquitetura (alto nível)
- Fluxo de dados
- Componentes

### Integrações
- APIs
- Banco de dados
- autenticação

### Segurança
- tratamento de dados
- privacidade

---

## 10. Fluxo funcional

- Passo a passo da interação
- Comportamento do sistema

---

## 11. Critérios de aceite (nível PRD / release)

**Escopo:** conjunto da entrega, incremento ou objetivo deste PRD — não substitui os critérios **por história** da seção 4.

- Como validar sucesso **do todo** (demo, go-live, critérios de aceite de release).
- Casos positivos e de erro **transversais** (fluxos ponta a ponta, integrações, SLAs agregados, regressão esperada).
- Deve ser **consistente** com os critérios por história (seção 4); **não** contradizer.

---

## 12. Riscos e dependências

- Pontos indefinidos
- Dependências externas
- riscos técnicos

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
- Se KPIs não forem definidos → PARAR
- Se não houver Non-Goals → PARAR
- Se Discovery não foi realizado → PARAR
- Se existir ambiguidade/trade-off não resolvido e o usuário ainda não escolheu opção nem critério decisório (ver *Ambiguidade, trade-offs e escolha do usuário*) → PARAR

---

## Importante

- NÃO implementar
- NÃO gerar código
- NÃO assumir comportamento
- NÃO inventar requisitos
- Este comando define a base de todo o sistema

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