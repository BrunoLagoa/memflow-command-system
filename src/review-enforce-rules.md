---
name: review-enforce-rules
description: Validação rígida adicional (opcional/recomendada) para cenários críticos — valida conformidade total com .agents, segurança client/server, arquitetura, fluxo do sistema e `model-policy.md` do target ativo (via `_shared/target-adapter.md`). Saída exclusiva: OK ou BLOQUEADO. Qualquer dúvida ou ambiguidade = BLOQUEADO. Não flexibiliza regras. Executar após /review quando necessário.
license: MIT
metadata:
  author: BrunoCastro
  version: "1.1.0"
---

Valide rigorosamente qualquer código, plano, decisão ou execução contra as regras do projeto.

---

## Referência normativa comum

Aplicar obrigatoriamente:

- `_shared/base-output.md`
- `_shared/base-preconditions.md`
- `_shared/base-degraded-mode.md`
- `_shared/target-adapter.md`

---

## Objetivo

Garantir que:

- nenhuma regra de `.agents` foi violada
- a implementação é segura
- a arquitetura foi respeitada
- o workflow do sistema foi seguido corretamente
- o uso de modelos está alinhado com `model-policy.md` do target ativo (via `_shared/target-adapter.md`)

Este é um **gate rígido opcional**, recomendado antes da conclusão em tarefas de maior risco ou criticidade.

---

## Importante

- Este comando é uma validação rígida opcional
- NÃO permitir continuidade com dúvidas
- NÃO aprovar parcialmente
- NÃO ignorar inconsistências
- Deve garantir consistência total do sistema

Este comando complementa validações anteriores com um critério mais estrito.

---

## Base de validação

Fonte de verdade absoluta:

- `.agents/**/*` (quando disponível)

Complementar:

- `docs/**/*`
- `model-policy.md` do target ativo (via `_shared/target-adapter.md`)
- decisões do `/workflow`
- plano (`/plan`)
- execução (`/execute`)

---

## Regras críticas

1. NÃO aceitar violações
2. NÃO flexibilizar regras
3. NÃO assumir comportamento implícito

4. Se houver **qualquer dúvida ou ambiguidade**:

→ considerar como violação
→ status = **BLOQUEADO**

---

## Verificações obrigatórias

### Regras técnicas

- Código segue `.agents`?
- Padrões definidos foram respeitados?

---

### Segurança (CRÍTICO)

- Existe exposição de secrets?
- Separação client/server correta?
- Respeita `.agents/rules/client-server-security.md`?

---

### Arquitetura

- Estrutura consistente com o projeto?
- Segue os padrões de stack definidos em `.agents`?
- Reutilização de código existente?
- Ausência de duplicação?

---

### Fluxo do sistema (CRÍTICO)

- `/workflow` foi utilizado?
- A decisão foi respeitada?
- `/execute` só iniciou após decisão explícita do `/workflow`?
- `/plan` foi usado quando necessário?
- `/execute` seguiu corretamente o fluxo?
- Houve bypass do sistema?

---

### Estratégia de execução

- Planejamento foi realizado quando necessário?
- Execução ocorreu de forma consistente?
- Houve execução sem contexto ou sem plano?

---

### Uso de modelo (ALINHADO AO MODEL-POLICY)

- Modelo foi coerente com a complexidade?
- Planejamento utilizou modelo adequado?
- Execução utilizou modelo econômico?
- Escalada foi aplicada corretamente?
- Houve uso indevido de modelo avançado?

---

### Qualidade do código

- Segue padrões de tipagem e verificação estática do projeto (conforme `.agents`)?
- Código limpo e legível?
- Sem lógica duplicada?

---

## Critérios de bloqueio

Status = **BLOQUEADO** se houver:

- violação de `.agents`
- falha de segurança
- inconsistência arquitetural
- quebra de fluxo do sistema
- ausência de planejamento quando necessário
- uso incorreto de modelo (contra `model-policy.md` do target ativo via `_shared/target-adapter.md`)
- ambiguidade não resolvida

Observação:

- ausência de `.agents`, isoladamente, NÃO bloqueia automaticamente; operar em modo degradado com alerta explícito

---

## Formato obrigatório de saída

Responda **sempre** com estes quatro títulos `##`, **nesta ordem** e **com estes nomes exatos**:

1. **Status** — somente `OK` ou `BLOQUEADO`
2. **Análise** — síntese clara do que foi validado
3. **Problemas** — lista objetiva de violações ou dúvidas
4. **Próximos passos** — ações obrigatórias para correção (sempre a **última** seção `##` da resposta)

Não omitir seções
Não renomear títulos
Não usar outros `##` principais

Em **Problemas**, listar cada violação encontrada, cada dúvida não resolvida e limitações de validação em modo degradado; se não houver → **Nenhum**.

Em **Próximos passos**: se **BLOQUEADO**, listar correções obrigatórias e indicar ações como `/plan`, `/execute`, `/debug`, `/refactor` ou esclarecimento do usuário; se **OK** → pode continuar.
