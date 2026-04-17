---
name: plan
description: Cria plano de implementação detalhado quando /workflow decide PLANEJAR PRIMEIRO, alinhado a ~/.config/opencode/commands/memflow/model-policy.md (global) ou .opencode/commands/memflow/model-policy.md (local) — sequência de passos, arquivos afetados, impacto, riscos e critérios de sucesso. Não escreve código. Saída: Status (Plano criado/Bloqueado), Análise com 9 subseções, Problemas e Próximos passos. Bloqueia se houver ambiguidade. Próximo passo: /execute.
license: MIT
metadata:
  author: BrunoCastro
  version: "1.0.0"
---

## Referência normativa comum

Aplicar obrigatoriamente `~/.config/opencode/commands/memflow/_shared/base-output.md` (global) ou `.opencode/commands/memflow/_shared/base-output.md` (local).
Aplicar obrigatoriamente `~/.config/opencode/commands/memflow/_shared/base-preconditions.md` (global) ou `.opencode/commands/memflow/_shared/base-preconditions.md` (local).
Aplicar obrigatoriamente `~/.config/opencode/commands/memflow/_shared/base-degraded-mode.md` (global) ou `.opencode/commands/memflow/_shared/base-degraded-mode.md` (local).
- Resolver essas referências somente pelos caminhos oficiais acima (sem fallback para o projeto aberto).

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
   - `~/.config/opencode/commands/memflow/model-policy.md (global) ou .opencode/commands/memflow/model-policy.md (local)`
   - estrutura real (via Serena, se disponível)
   - resolver `~/.config/opencode/commands/memflow/model-policy.md (global) ou .opencode/commands/memflow/model-policy.md (local)` apenas nesses caminhos oficiais

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

## Formato obrigatório de saída

## Status

- Plano criado / Bloqueado

---

## Análise

### Entendimento

- O que precisa ser feito

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
- quando a atividade for grande, sugerir divisão em tarefas menores/subtarefas para facilitar execução

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

## Próximos passos

- Aguardar confirmação
- Ajustar plano (se necessário)
- Seguir para `/execute`

---

## Modelo recomendado

- Modelo: (ex: GPT-5.4)
- Justificativa:
  - complexidade
  - impacto
  - risco

---

## Regras específicas

- NÃO planejar com base em suposição
- NÃO criar arquivos sem validar necessidade
- NÃO ignorar padrões existentes
- Sugestão: se a atividade envolver muitas áreas, arquivos ou dependências, quebrar em tarefas menores/subtarefas para facilitar desenvolvimento, validação e acompanhamento

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
