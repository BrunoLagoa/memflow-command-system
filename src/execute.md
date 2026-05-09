---
name: execute
description: Implementa código com base na decisão do /workflow respeitando `model-policy.md` do target ativo. Sem decisão explícita do /workflow, bloqueia e retorna para orquestração. Inclui integração com persistência inteligente e métricas de qualidade.
license: MIT
metadata:
  author: BrunoCastro
  version: "3.3.0"
---

## Referência normativa comum

Aplicar obrigatoriamente:

- `_shared/base-output.md`
- `_shared/base-preconditions.md`
- `_shared/base-degraded-mode.md`
- `_shared/target-adapter.md`
- `model-policy.md`

---

## Objetivo

Executar a implementação:

- respeitando a decisão do `/workflow`
- seguindo `model-policy.md`
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
- NÃO → BLOQUEAR e retornar ao `/workflow`

---

## Sem decisão do `/workflow`

- Status: Parcial
- Motivo: decisão de estratégia ausente
- Ação obrigatória: executar `/workflow`
- NÃO classificar complexidade/impacto/risco dentro de `/execute`

E PARAR.

---

## Gate anti-compaction (OBRIGATÓRIO)

Antes de executar implementação, validar no contexto ativo:

- idioma pt-BR confirmado
- identidade Memflow confirmada

Se qualquer um estiver ausente ou falhar:

- Status: Parcial
- Motivo: invariantes anti-compaction inválidos
- Ação obrigatória: reexecutar `/context`
- NÃO implementar até revalidação

E PARAR.

---

## Integração com `/workflow`

- EXECUTAR DIRETO → executar  
- PLANEJAR → bloquear  

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

## Integração com plano salvo (Plano vivo)

Quando houver plano salvo em `.md`:

- ler o plano salvo antes de iniciar a implementação
- mapear tarefas/subtarefas planejadas para a execução atual
- respeitar o modo de execução definido no plano:
  - `[P]` paralelizável: pode executar em paralelo com outras `[P]` quando não houver conflito
  - `[S]` sequencial: executar na ordem planejada
- atualizar o checklist de progresso no plano salvo durante a execução usando a legenda padrão:
  - `[ ]` pendente
  - `[-]` em andamento
  - `[x]` concluída
  - `[!]` bloqueada
- preservar os marcadores de modo `[P]` e `[S]` durante as atualizações de status
- manter consistência entre tarefa pai e subtarefas ao atualizar status:
  - só marcar tarefa pai como `[x]` quando todas as subtarefas estiverem `[x]`
  - quando houver subtarefa `[-]`, refletir tarefa pai como `[-]`
  - quando houver subtarefa `[!]`, não marcar tarefa pai como `[x]`
- atualizar em ordem top-down (tarefa pai -> subtarefa) para evitar estado contraditório
- quando houver item `[!]`, registrar no plano salvo:
  - motivo objetivo do bloqueio
  - ação necessária para desbloqueio
  - responsável esperado pela ação (usuário, agente ou sistema externo)
  - critério de saída para retornar a `[ ]` ou `[-]`
- atualizar o último checkpoint e o próximo passo ao final da execução
- se a execução parar no meio, registrar claramente onde parou e o que falta para retomar

Se não houver plano salvo:

- executar normalmente com base na decisão do `/workflow`

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

Se erro → corrigir automaticamente  

---

## Regras específicas

- NÃO sobrescrever sem análise  
- NÃO duplicar código  
- NÃO alterar múltiplos arquivos sem necessidade  
- NÃO autoexecutar próximos comandos do fluxo sem confirmação do usuário
- NÃO encerrar execução com plano salvo desatualizado quando houve avanço em tarefas/subtarefas

---

## Resiliência

- erro simples → corrigir  
- erro estrutural → revisar plano  
- erro recorrente → escalar  

---

# Persistência inteligente (AUTO MEMORY)

Após execução, avaliar relevância para memória.

---

## Avaliação de relevância

Verificar se houve:

- decisões técnicas  
- mudanças relevantes  
- padrões definidos  
- escolhas arquiteturais  
- contexto útil  

---

## Detecção de decisões

Detectar padrões:

- “vamos usar…”  
- “decidimos…”  
- “padronizar…”  
- “não usar mais…”  
- “a partir de agora…”  

---

## Score de relevância (0–100)

- Mudança de stack: +40  
- Decisão arquitetural: +30  
- Padrão global: +20  
- Impacto múltiplos arquivos: +10  
- Mudança local: +5  
- Ajuste trivial: 0  

---

## Interpretação

- 0–20 → Não salvar  
- 21–50 → Pode salvar  
- 51–80 → Recomendar  
- 81–100 → Recomendar fortemente  

---

## Resultado

Se score ≥ 51:

→ Executar `/memory-save`

Se score < 51:

→ Não necessário salvar  

---

# 🆕 Integração com métricas de qualidade (NOVO)

Se a execução for seguida de:

- `/review`
- `/review-code`

Então:

→ Priorizar execução do `/memory-save`

Objetivo:

- registrar qualidade da execução  
- alimentar histórico do sistema  
- permitir análise futura  

---

## Importante

- NÃO decidir estratégia  
- NÃO pular validações  
- NÃO finalizar com erro  
- NÃO executar sem entendimento  

---

# Formato obrigatório de saída

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
- Plano salvo atualizado: SIM / NÃO / N/A
- Checkpoint de retomada registrado: SIM / NÃO / N/A

---

## Problemas

- Erros ou riscos  
- Impactos  

Se não houver:
→ Nenhum  

---

## Persistência sugerida

- Score de relevância: X/100  
- Conteúdo relevante: SIM / NÃO  
- Decisões detectadas: SIM / NÃO  
- Métricas de qualidade elegíveis: SIM / NÃO  
- Recomendação:
  - Executar `/memory-save`
  - Não necessário salvar  

---

## Bloqueios

- Plano necessário → PARAR  
- Conflito com `.agents` → PARAR  
- Falta de contexto → PARAR  
- Falha de invariantes anti-compaction → PARAR

---

## Próximos passos

- `/review`  
- `/review-code` (se aplicável)  
- `/memory-save` (recomendado após validação)  
- `/review-enforce-rules` (opcional)  
- `/test-plan` (se aplicável)  
- Aguardar confirmação explícita do usuário antes de executar qualquer próximo comando