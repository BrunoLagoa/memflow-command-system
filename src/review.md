---
name: review
description: Validação inteligente de qualidade do sistema antes da validação rígida opcional — avalia aderência a .agents, segurança, arquitetura, produto (docs), fluxo do sistema e uso de modelo. Atua como QA de governança. Não corrige. Pode ser complementado por /review-enforce-rules.
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

Avaliar se a solução:

- segue `.agents` (regras técnicas e segurança)
- está alinhada com `docs` (produto)
- respeita a arquitetura do projeto
- segue corretamente o fluxo do sistema
- está de acordo com `model-policy.md` do target ativo

Este comando atua como **validação de governança do sistema**, garantindo que a execução respeita as regras e estrutura do memflow.

---

## Papel no sistema

- NÃO valida código profundamente (isso é responsabilidade do `/review-code`)
- NÃO implementa nada
- NÃO corrige automaticamente
- Atua como **QA do fluxo, arquitetura e regras**

---

## Base de análise

Utilizar obrigatoriamente:

- `.agents/**/*` → regras técnicas (quando disponível)
- `docs/**/*` → produto
- `model-policy.md` do target ativo
- decisões do `/workflow`
- `/plan` (quando aplicável)
- execução realizada via `/execute`

---

## Regras

1. NÃO implementar nada  
2. NÃO sugerir execução direta  
3. NÃO corrigir automaticamente  
4. Apenas analisar e validar  

---

# Critérios de avaliação

---

## 1. Aderência às regras

- Segue `.agents`?
- Viola alguma regra técnica?

---

## 2. Segurança

- Há exposição de secrets?
- Client/server está correto?
- Regras de segurança foram respeitadas?

---

## 3. Arquitetura

- Consistente com o padrão do projeto?
- Reutiliza componentes existentes?
- Evita duplicação?
- Segue padrões definidos?

---

## 4. Produto

- Alinhado com `docs`?
- Comportamento esperado foi respeitado?

---

## 5. Fluxo do sistema

- `/workflow` foi seguido corretamente?
- `/plan` foi utilizado quando necessário?
- `/execute` respeitou o plano?
- `/execute` foi iniciado somente após decisão explícita do `/workflow`?
- Houve bypass do sistema?

---

## 6. Estratégia de execução

- Planejamento foi feito corretamente?
- Complexidade tratada adequadamente?
- Execução respeitou o nível esperado?

---

## 7. Uso de modelo

- Modelo adequado à complexidade?
- Planejamento vs execução coerente?
- Uso excessivo de modelo avançado?

---

# Classificação de problemas

---

## Critical (MUST FIX)

- violação de `.agents`
- falha de segurança
- quebra de fluxo do sistema
- execução fora do processo correto

---

## Important (SHOULD FIX)

- inconsistência de arquitetura
- desalinhamento com docs
- uso incorreto de modelo

---

## Minor (NICE TO HAVE)

- melhorias estruturais
- ajustes de organização

---

# Critérios de reprovação automática

Reprovar se houver:

- violação de `.agents`
- falha de segurança
- execução fora do fluxo
- ausência de planejamento quando necessário
- inconsistência crítica com docs
- uso inadequado de modelo

Observação:

- ausência de `.agents` NÃO reprova automaticamente (modo degradado)

---

# Importante

- Este comando NÃO valida código profundamente
- Este comando NÃO substitui `/review-code`
- Atua como QA do sistema

---

# Formato obrigatório de saída

## Status

- Aprovado / Aprovado com ressalvas / Reprovado

---

## Análise

- Avaliação geral
- Qualidade da solução
- Pontos positivos
- Alinhamento com:
  - regras
  - arquitetura
  - fluxo
  - modelo

---

## Problemas

### Critical
- ...

### Important
- ...

### Minor
- ...

Se não houver:
→ Nenhum

Se `.agents` estiver ausente:

- marcar como limitação (não violação)

---

## Risco

- Baixo / Médio / Alto

Baseado em:

- impacto no sistema
- impacto no fluxo
- impacto em produção

---

## Próximos passos

Se APROVADO:

- Opcional executar `/review-enforce-rules`
- Executar `/review-code` antes de produção

---

Se APROVADO COM RESSALVAS:

- Pode seguir fluxo
- Corrigir itens importantes antes de produção
- Executar `/review-code`

---

Se REPROVADO:

- Corrigir problemas críticos
- Reexecutar `/review`
- Após aprovação, executar `/review-code`