---
name: review-code
description: Avalia qualidade técnica da implementação comparando código com PRD/SPEC/PLAN. Foco em bugs, arquitetura, testes e readiness para produção. Não implementa. Não corrige. Apenas analisa.
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

Validar a qualidade técnica da implementação:

- aderência ao `/spec` e `/plan`
- qualidade de código
- arquitetura
- testes
- readiness para produção

Este comando atua como **validação técnica final antes de produção**.

---

## Entrada esperada

- descrição do que foi implementado
- referência ao `/plan`
- referência ao `/spec`
- diff de código (quando aplicável)

Se incompleto:
→ BLOQUEAR

---

## Regras

1. NÃO implementar nada
2. NÃO corrigir automaticamente
3. NÃO assumir comportamento não definido no spec
4. Apenas analisar

---

# Critérios de avaliação

---

## 1. Aderência ao SPEC

- segue contratos de input/output?
- comportamento está correto?
- regras foram respeitadas?
- há divergência?

---

## 2. Qualidade de código

- código claro e legível?
- separação de responsabilidades?
- duplicação evitada (DRY)?
- tipagem correta (se aplicável)?
- tratamento de erros adequado?

---

## 3. Arquitetura

- estrutura consistente com o projeto?
- componentes bem definidos?
- escalável?
- performance considerada?

---

## 4. Testes

- existem testes?
- cobrem lógica real?
- cobrem edge cases?
- são confiáveis (não apenas mocks)?

---

## 5. Segurança

- exposição de secrets?
- validação de input adequada?
- falhas de segurança evidentes?

---

## 6. Produção (Readiness)

- backward compatibility considerada?
- erros tratados corretamente?
- logs adequados?
- comportamento previsível?

---

## Classificação de problemas

### Critical (MUST FIX)

- bugs
- falhas de segurança
- quebra de funcionalidade
- violação do spec

---

### Important (SHOULD FIX)

- problemas de arquitetura
- ausência de testes relevantes
- tratamento de erro insuficiente

---

### Minor (NICE TO HAVE)

- melhorias de código
- legibilidade
- otimizações

---

## Importante

- Este comando NÃO valida fluxo do memflow (isso é papel do `/review`)
- Este comando NÃO substitui `/review`
- Este comando valida a implementação real

---

# Formato obrigatório de saída

## Status

- Aprovado / Aprovado com ressalvas / Reprovado

---

## Strengths

- Pontos positivos claros

---

## Issues

### Critical
- ...

### Important
- ...

### Minor
- ...

Se não houver:
→ Nenhum

---

## Recommendations

- melhorias sugeridas

---

## Assessment

Ready to merge: Yes / No / With fixes

Reasoning:
- avaliação técnica objetiva

---

## Próximos passos

Se APROVADO:

- pronto para produção

Se COM RESSALVAS:

- corrigir itens importantes antes de merge

Se REPROVADO:

- corrigir críticos
- reexecutar `/review-code`