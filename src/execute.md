---
name: execute
description: Implementa código com base na decisão do /workflow respeitando ~/.config/opencode/commands/model-policy.md — executa direto ou bloqueia e exige /plan. Inclui recomendação inteligente de persistência de memória ao final.
license: MIT
metadata:
  author: BrunoCastro
  version: "3.0.0"
---

## Referência normativa comum

Aplicar obrigatoriamente:

- ~/.config/opencode/commands/_shared/base-output.md
- ~/.config/opencode/commands/_shared/base-preconditions.md
- ~/.config/opencode/commands/_shared/base-degraded-mode.md

---

## Objetivo

Executar a implementação:

- respeitando a decisão do `/workflow`
- seguindo `~/.config/opencode/commands/model-policy.md`
- mantendo consistência com `.agents` e `docs`

Este comando NÃO decide estratégia, apenas executa.

---

## Uso de ferramentas MCP

### Serena MCP (PRIORIDADE)

- localizar pontos exatos de alteração
- editar código com precisão
- evitar duplicação
- entender dependências

Priorizar:

- find_symbol
- find_referencing_symbols
- replace_symbol_body
- insert_before_symbol / insert_after_symbol

Evitar:

- editar arquivos inteiros sem necessidade

---

## Validação de decisão (OBRIGATÓRIO)

### Existe decisão do `/workflow`?

- SIM → seguir decisão
- NÃO → aplicar fallback controlado

---

## Fallback controlado

Classificar:

- Complexidade
- Impacto
- Risco

---

### EXECUTAR DIRETO se:

- baixa complexidade
- baixo impacto
- baixo risco

---

### EXIGIR `/plan` se:

- média ou alta complexidade
- médio ou alto impacto
- médio ou alto risco

---

### Se exigir plano:

- Status: Parcial
- Motivo: ausência de planejamento
- Próximo passo: `/plan`

E PARAR.

---

## Integração com `/workflow`

- EXECUTAR DIRETO → executar
- PLANEJAR → bloquear e exigir `/plan`

---

## Uso de modelo

- seguir model-policy
- execução → modelo econômico
- escalar apenas se necessário

---

## Escalada

1ª falha → corrigir  
2ª falha → revisar abordagem  
3ª falha → escalar modelo  

---

## Execução

- implementar código
- ajustar arquivos
- seguir padrões do projeto

---

## Segurança

- respeitar `.agents`
- evitar exposição de secrets
- separar client/server corretamente

Se `.agents` ausente:
- aplicar boas práticas
- modo degradado

---

## Testes

- detectar runtime
- rodar testes relevantes
- evitar regressão

---

## Detecção de stack

Identificar:

- linguagem/runtime
- gerenciador
- comandos de lint/test

---

## Qualidade obrigatória

Após implementar:

1. setup (se necessário)
2. format
3. lint/typecheck
4. testes

Se erro:
→ corrigir automaticamente

---

## Regras específicas

- NÃO sobrescrever sem análise
- NÃO duplicar código
- NÃO alterar múltiplos arquivos sem necessidade

---

## Resiliência

- erro simples → corrigir
- erro estrutural → revisar plano
- erro recorrente → escalar

---

## Persistência sugerida (AUTO MEMORY)

Após a execução, avaliar se há conteúdo relevante para memória.

---

### Avaliação de relevância

Verificar se houve:

- decisões técnicas
- mudanças relevantes
- padrões definidos
- escolhas arquiteturais
- contexto útil para futuras sessões

---

### Detecção de decisões

Identificar padrões como:

- “vamos usar…”
- “decidimos…”
- “padronizar…”
- “não usar mais…”
- “a partir de agora…”

---

## Score de relevância (0–100)

Calcular com base nos critérios:

- Mudança de stack: +40
- Decisão arquitetural: +30
- Definição de padrão global: +20
- Impacto em múltiplos arquivos: +10
- Mudança local relevante: +5
- Ajuste trivial: 0

Regras:

- Somar apenas critérios aplicáveis
- Limite máximo: 100
- Não duplicar critérios equivalentes

---

## Interpretação do score

- 0–20   → Não salvar
- 21–50  → Pode salvar
- 51–80  → Recomendar salvar
- 81–100 → Recomendar fortemente salvar

---

## Resultado da avaliação

### Se score >= 51:

Recomendar:

→ Executar `/memory-save`

---

### Se score < 51:

Recomendar:

→ Não é necessário salvar

---

## Formato obrigatório de saída

## Status

- Executado / Falhou / Parcial

---

## Análise

- O que foi feito
- Arquivos alterados
- Uso de Serena
- Uso de fallback
- Aderência ao workflow
- Modo: Normal / Degradado

---

## Problemas

- Erros ou riscos
- Impactos

Se não houver:
→ Nenhum

---

## Próximos passos

- `/review`
- `/review-enforce-rules`
- `/test-plan` (se aplicável)
- Se `/review` não for executado: rodar check silencioso de versão do MEMFLOW ao final (exibir aviso somente quando houver atualização)

---

## Persistência sugerida

- Score de relevância: X/100
- Conteúdo relevante detectado: SIM / NÃO
- Decisões detectadas: SIM / NÃO
- Recomendação:
  - Executar `/memory-save`
  - Não necessário salvar

---

## Bloqueios

- Plano necessário → PARAR
- Conflito com `.agents` → PARAR
- Falta de contexto → PARAR

---

## Importante

- NÃO decidir estratégia
- NÃO pular validações
- NÃO finalizar com erro
- NÃO executar sem entendimento