---
name: plan
description: Cria plano de implementação detalhado quando /workflow decide PLANEJAR PRIMEIRO, alinhado a `model-policy.md` do target ativo (via `_shared/target-adapter.md`) — sequência de passos, arquivos afetados, impacto, riscos e critérios de sucesso. Não escreve código. Saída: Status (Plano criado/Bloqueado), Análise com 9 subseções, Problemas e Próximos passos. Bloqueia se houver ambiguidade. Próximo passo: /execute.
license: MIT
metadata:
  author: BrunoCastro
  version: "1.1.0"
---

## Referência normativa comum

Aplicar obrigatoriamente:

- `_shared/base-output.md`
- `_shared/base-preconditions.md`
- `_shared/base-degraded-mode.md`
- `_shared/target-adapter.md`
- `model-policy.md`
- Resolver essas referências conforme `_shared/target-adapter.md` (sem fallback fora do target ativo).

---

## Objetivo

Criar um plano de implementação:

- claro
- completo
- sem ambiguidades
- pronto para execução via `/execute`

---

## Integração com sistema (CRÍTICO)

Este comando:

- DEVE ser usado quando `/workflow` decidir → PLANEJAR PRIMEIRO
- NÃO deve ser usado fora desse contexto sem validação

---

## Uso de ferramentas MCP

Se disponível:

### Serena MCP (PRIORIDADE)

- validar estrutura real do código
- identificar pontos exatos de implementação
- localizar arquivos e dependências
- evitar duplicação

Priorizar:

- find_symbol
- find_referencing_symbols
- search_for_pattern
- get_symbols_overview

Evitar:

- assumir estrutura
- planejar arquivos inexistentes

---

## Uso de modelo (ALINHADO AO MODEL-POLICY)

Este comando deve:

- utilizar modelo mais inteligente (ex: GPT-5.4)
- priorizar qualidade sobre custo

---

### Regra principal

- Planejamento → modelo mais forte
- Execução → modelo mais econômico

---

## Regras obrigatórias

1. Basear-se em:
   - `.agents` (quando disponível)
   - `docs`
   - `model-policy.md` resolvido pelo target ativo (via `_shared/target-adapter.md`)
   - estrutura real (via Serena, se disponível)
   - resolver `model-policy.md` com as regras do target ativo (via `_shared/target-adapter.md`)

2. NÃO escrever código

3. NÃO assumir comportamento não definido

4. Se houver ambiguidade → PARAR

5. Se houver conflito → PARAR

---

## Validação antes de planejar

Antes de gerar o plano:

- O problema está claro?
- O escopo está definido?
- Existe contexto suficiente?

Se NÃO:
→ PARAR e solicitar esclarecimento

---

## Confirmação obrigatória de salvamento (ANTES de qualquer planejamento)

Antes de iniciar a análise e criação do plano, PERGUNTAR ao usuário:

- Deseja salvar o plano que será criado para manter os dados documentados?

Apresentar obrigatoriamente opções claras:

- Sim, salvar o plano
- Não, apenas mostrar no chat

Regras:

- NÃO iniciar o planejamento antes da resposta do usuário
- Se a resposta estiver ambígua, perguntar novamente usando as mesmas opções
- Se já existir preferência explícita de salvamento na sessão atual, reutilizar essa preferência por padrão e apenas confirmar quando houver mudança solicitada
- Registrar no plano a preferência escolhida (salvar ou não salvar)
- Se o usuário escolher salvar, incluir no plano onde o conteúdo será documentado
- Se o usuário escolher salvar, estruturar o documento como plano vivo com checklist de progresso por tarefa/subtarefa para atualização durante `/execute`

---

## Regras específicas

- NÃO planejar com base em suposição
- NÃO criar arquivos sem validar necessidade
- NÃO ignorar padrões existentes
- DEVE dimensionar a quantidade de tarefas conforme complexidade e escopo real, sem reutilizar quantidade fixa entre planos
- DEVE aplicar sizing dinâmico para passos de implementação:
  - baixa complexidade: 3-5 tarefas
  - média complexidade: 6-10 tarefas
  - alta complexidade: 10+ tarefas com subtarefas obrigatórias

---

## Limitações

Se Serena NÃO estiver disponível:

- avisar limitação
- planejar com base nos arquivos disponíveis

Se `.agents` NÃO estiver disponível:

- avisar limitação
- manter plano em modo degradado
- não bloquear automaticamente por esse motivo

---

## Bloqueios

- Falta de contexto → PARAR
- Ambiguidade → PARAR
- Conflito com `.agents` (quando existir) → PARAR
- Estrutura desconhecida → PARAR

---

## Importante

- NÃO implementar
- NÃO avançar sem clareza total
- NÃO seguir para `/execute` sem validação
- Este comando define a qualidade da execução

---

## Formato obrigatório de saída

## Status

- Plano criado / Bloqueado

---

## Análise

### Entendimento

- O que precisa ser feito

---

### Preferência de salvamento

- Decisão do usuário: Salvar / Não salvar
- Quando salvar: destino de documentação definido

---

### Regras aplicáveis

- `.agents` relevantes (ou ausência em modo degradado)
- segurança (se aplicável)

---

### Estratégia

- abordagem de alto nível
- alinhamento com arquitetura existente

---

### Passos de implementação

- sequência clara e executável
- baseada em estrutura real (quando possível)
- quantidade de tarefas definida por sizing dinâmico (complexidade + escopo real), sem quantidade fixa reutilizada entre planos
- para alta complexidade, incluir obrigatoriamente subtarefas
- checklist final obrigatório de granularidade: cada item pode ser executado sem ambiguidades?
- classificar cada tarefa como:
  - `[P]` paralelizável (pode executar em paralelo)
  - `[S]` sequencial (depende de ordem)

---

### Arquivos afetados

- arquivos a criar ou alterar
- validar com Serena (se disponível)

---

### Impacto

- áreas afetadas
- dependências envolvidas

---

### Riscos

- técnicos
- de negócio
- efeitos colaterais

---

### Critérios de sucesso

- como validar após `/execute`

---

### Rastreamento de execução (Plano vivo)

- obrigatório quando a preferência for salvar o plano
- incluir checklist por tarefa/subtarefa com status: pendente / em andamento / concluída / bloqueada
- incluir último checkpoint de execução e próximo passo objetivo para retomada
- incluir marcador de modo de execução por tarefa/subtarefa:
  - `[P]` paralelizável
  - `[S]` sequencial
- usar template padrão de checklist para consistência:
  - `[ ]` pendente
  - `[-]` em andamento
  - `[x]` concluída
  - `[!]` bloqueada
- critérios obrigatórios para marcar `[P]`:
  - sem dependência de saída de outra tarefa
  - sem conflito previsível de arquivos/áreas críticas
  - sem bloqueio por estado compartilhado sensível
  - com merge e rollback isoláveis
- se qualquer critério falhar, classificar como `[S]`
- aplicar consistência de status entre tarefa pai e subtarefas:
  - tarefa pai só pode ser `[x]` quando todas as subtarefas estiverem `[x]`
  - se existir subtarefa `[-]`, a tarefa pai deve ficar `[-]`
  - se existir subtarefa `[!]`, a tarefa pai não pode ficar `[x]`
  - manter atualização em ordem top-down (tarefa pai -> subtarefa) para evitar divergência
- para itens `[!]` (bloqueada), registrar obrigatoriamente:
  - motivo objetivo do bloqueio
  - ação necessária para desbloqueio
  - responsável esperado pela ação (usuário, agente ou sistema externo)
  - critério de saída do bloqueio para retornar a `[ ]` ou `[-]`

Template base recomendado:

```md
### Progresso de execução

- [P][ ] Tarefa 1
  - [S][-] Subtarefa 1.1
  - [P][x] Subtarefa 1.2
- [S][!] Tarefa 2 (motivo do bloqueio)
  - Ação de desbloqueio: <ação objetiva>
  - Responsável: <usuário | agente | sistema externo>
  - Critério de saída: <condição para voltar a [ ] ou [-]>

Último checkpoint: <resumo objetivo do último ponto executado>
Próximo passo: <ação objetiva para retomada>
```

---

### Fora de escopo

- o que NÃO será feito

---

### Confiança no plano

- Baixa / Média / Alta

---

### Modo de operação

- Normal / Degradado
- Impacto da ausência de `.agents` (quando aplicável)

---

## Problemas

- ambiguidades
- falta de contexto
- conflitos com `.agents` ou `docs`
- limitações de Serena

Se não houver:
→ Nenhum

---

## Modelo recomendado

- Modelo: (ex: GPT-5.4)
- Justificativa:
  - complexidade
  - impacto
  - risco

---

## Próximos passos

- Aguardar confirmação
- Ajustar plano (se necessário)
- Seguir para `/execute`
- Quando houver plano salvo: manter o checklist e checkpoint atualizados durante a execução
