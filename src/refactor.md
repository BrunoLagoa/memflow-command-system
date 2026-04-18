---
name: refactor
description: Analisa e propõe refatoração de código — identifica duplicação, baixa legibilidade e violações de padrões. Classifica risco (Baixo/Médio/Alto). Não aplica mudanças automaticamente; aguarda confirmação explícita. Saída: Status (Análise concluída/Bloqueado), diagnóstico e proposta de mudanças. Bloqueia execução se risco Alto sem confirmação.
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

Refatorar código:

- mantendo comportamento funcional
- melhorando qualidade, legibilidade e estrutura
- respeitando `.agents` e `docs`

---

## Regras obrigatórias

1. Seguir obrigatoriamente:
   - `.agents` (padrões técnicos e segurança)
   - `docs` (comportamento esperado)

2. NÃO alterar comportamento funcional sem aviso explícito

3. NÃO introduzir nova arquitetura sem validação

---

## Uso de modelo (ALINHADO AO MODEL-POLICY)

Este comando deve:

- utilizar modelo intermediário ou avançado
- priorizar qualidade de análise e segurança da refatoração
- seguir `model-policy.md` resolvido pelo target ativo (via `_shared/target-adapter.md`)
- resolver `model-policy.md` com as regras do target ativo (via `_shared/target-adapter.md`)

---

## Análise obrigatória

Antes de qualquer refatoração, identificar:

### Problema atual

- Código duplicado
- Baixa legibilidade
- Violação de padrões
- Complexidade desnecessária

---

### Regras aplicáveis

- Quais regras de `.agents` estão sendo violadas ou não seguidas
- Padrões que deveriam ser aplicados

---

### Estratégia de refatoração

- Como o código será melhorado
- Qual abordagem será usada (ex: extração de função, simplificação, separação de responsabilidade)

---

### Mudanças propostas

- Lista clara e objetiva do que será alterado

---

### Riscos

Classificar:

- Baixo
- Médio
- Alto

E explicar:

- o que pode quebrar
- impacto possível

---

## Validação de risco

- Se risco = ALTO:
  - AVISAR
  - NÃO executar automaticamente
  - Aguardar confirmação

- Se houver violação de `.agents`:
  - PARAR
  - Explicar o problema

---

## Bloqueio de execução

Este comando NÃO deve aplicar mudanças automaticamente.

Sempre:

- apresentar análise completa
- aguardar confirmação explícita do usuário

---

## Importante

- NÃO executar refatoração automaticamente
- NÃO alterar comportamento sem autorização
- Este comando é apenas de análise + proposta

---

## Formato obrigatório de saída

Responda SEMPRE com:

## Status

- Análise concluída / Bloqueado

---

## Análise

- Diagnóstico do código atual
- Problemas encontrados
- Qualidade atual

---

## Problemas

- Lista clara dos pontos que precisam refatoração
- Se não houver: Nenhum

---

## Próximos passos

- Confirmar se deve aplicar refatoração
- Ou ajustar estratégia
