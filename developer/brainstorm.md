---
name: brainstorm
description: Brainstorming estruturado antes de qualquer implementação — explora o problema em fases conversacionais, gera 2 a 5 abordagens com prós/contras, design proposto, riscos e recomendação. Inclui HARD-GATE anti-bypass, perguntas em rodadas por fronteira de decisões com opções selecionáveis e resposta recomendada, refinamento do modelo de domínio (glossário e ADRs), modo mapa para esforços multi-sessão, subagents opcionais para levantamento de fatos, auto-revisão, gate de salvamento e critérios de prontidão (DoD). Saída: Status, Análise, Problemas e Próximos passos. Pré-requisito: /context. Próximo passo: /prd, /spec ou /plan (conforme gate). Não implementa nada.
license: MIT
metadata:
  author: BrunoCastro
  version: "1.5.0"
---

## Referência normativa comum

Aplicar obrigatoriamente:

- `_shared/base-output.md`
- `_shared/base-preconditions.md`
- `_shared/base-degraded-mode.md`
- `_shared/base-domain-model.md`
- `_shared/base-subagents.md`
- `_shared/target-adapter.md`
- `model-policy.md`
- Resolver essas referências conforme `_shared/target-adapter.md` (sem fallback fora do target ativo).

---

## Integração com sistema (CRÍTICO)

Este comando:

- DEVE ser usado quando `/workflow` decidir → EXPLORAR PRIMEIRO
- PODE ser usado antes de `/prd`, `/spec` ou `/plan` quando houver trade-offs ou clareza insuficiente
- NÃO substitui `/prd`, `/spec` ou `/plan` — prepara a decisão para o próximo passo
- NÃO deve invocar `/execute` ou qualquer implementação

Handoff permitido (decidir no gate final):

- `/prd` — falta definição de produto, escopo ou critérios de negócio
- `/spec` — PRD existe, falta decisão técnica determinística
- `/plan` — escopo e abordagem já estão claros o suficiente para planejar implementação

---

## Gate obrigatório (HARD-GATE)

NÃO invocar `/execute`, escrever código, scaffoldar projeto ou tomar qualquer ação de implementação até:

1. apresentar a recomendação completa
2. concluir auto-revisão
3. obter aprovação explícita do usuário

Isso vale para **toda** tarefa, independentemente da complexidade percebida.

### Anti-padrão: "É simples demais para precisar de brainstorm"

Tarefas simples podem ter design curto (poucas frases), mas **sempre** passam pelo gate. Projetos "simples" são onde premissas não examinadas geram mais retrabalho.

Violação do HARD-GATE → status `Bloqueado`.

---

## Objetivo

Explorar múltiplas abordagens possíveis antes de definir uma solução, com validação incremental e handoff claro para o próximo comando do SDLC.

---

## Uso de modelo (ALINHADO AO MODEL-POLICY)

- **Fases 1–2 (contexto e abordagens):** modelo econômico por padrão
- **Validação no código (Serena) e comparação de trade-offs:** modelo intermediário quando complexidade ≥ média
- **Recomendação final, design proposto e DoD:** modelo mais forte quando complexidade ≥ média ou risco ≥ médio
- Escalar apenas quando a qualidade da decisão justificar

---

## Uso de ferramentas MCP

Se disponível:

### Serena MCP

- Utilize para:
  - entender a estrutura real do código
  - identificar padrões existentes
  - localizar implementações similares
  - validar suposições sobre arquitetura
- Priorizar:
  - find_symbol
  - find_referencing_symbols
  - search_for_pattern
  - get_symbols_overview
- Evitar:
  - assumir estrutura sem validação
  - basear decisões apenas em nomes de arquivos

---

## Recursos visuais (opcional)

Decidir **por pergunta**, não por sessão inteira.

**Usar diagrama ou mockup** (Mermaid, canvas ou equivalente) quando o conteúdo **for visual**:

- layout de UI, wireframes, comparação side-by-side
- arquitetura de componentes, fluxo de dados, máquina de estados

**Usar terminal/texto** quando o conteúdo for conceitual:

- trade-offs, escopo, critérios de sucesso, decisões de API
- perguntas de requisito ou clarificação

Pergunta sobre UI não é automaticamente visual. "O que significa X neste contexto?" → texto. "Qual layout funciona melhor?" → visual.

---

## Processo em fases (OBRIGATÓRIO)

Executar em ordem. Não pular fases. Avançar só após validação da fase atual.

| Fase | Objetivo | Status típico |
|------|----------|---------------|
| 1/4 | Contexto, premissas e lacunas | `Em exploração (fase 1/4)` ou `Aguardando resposta` |
| 2/4 | Abordagens, prós/contras e complexidade | `Em exploração (fase 2/4)` ou `Aguardando resposta` |
| 3/4 | Design proposto, riscos, critérios e recomendação | `Em exploração (fase 3/4)` ou `Aguardando resposta` |
| 4/4 | Auto-revisão, gate de salvamento e handoff | `Em exploração (fase 4/4)` → status final de prontidão |

### Fase 1 — Contexto e lacunas

- Explorar `.agents`, `docs` e código real (Serena, quando disponível)
- Se o escopo descrever múltiplos subsistemas independentes → **decompor primeiro** (ver seção abaixo)
- Identificar premissas validadas vs. não validadas
- Levantar por conta própria todo **fato** disponível no código, docs ou MCP (ver Rodadas de perguntas)
- Perguntar as **decisões** restantes em **rodadas por fronteira** (ver Rodadas de perguntas)
- Aplicar refinamento de domínio: desafiar termos contra o glossário e afiar linguagem vaga
- Validar entendimento antes de avançar

### Fase 2 — Abordagens

- Propor **2 a 5** abordagens distintas
- Comparar prós, contras e complexidade (Baixa / Média / Alta)
- Basear em padrões reais do código quando possível
- **NÃO** fechar uma única solução ainda

### Fase 3 — Design e recomendação

- Apresentar design proposto (escala por complexidade)
- Definir critérios de sucesso, riscos e aderência ao projeto
- Registrar recomendação, opções rejeitadas e confiança
- Solicitar validação da recomendação ao usuário

### Fase 4 — Auto-revisão, salvamento e handoff

- Executar auto-revisão (ver seção abaixo)
- Confirmar registro de termos de domínio resolvidos e ADRs candidatos (ver Modelo de domínio)
- Perguntar gate de salvamento (se ainda não respondido)
- Definir próximo comando: `/prd`, `/spec` ou `/plan`
- Marcar status de prontidão somente após aprovação explícita

---

## Diálogo estruturado (OBRIGATÓRIO)

Quando precisar de input do usuário:

- apresentar opções em diálogo estruturado e selecionável
- **preferir múltipla escolha** (A/B/C/D) em vez de pergunta aberta
- **uma rodada por mensagem** (ver Rodadas de perguntas); cada pergunta da rodada tem suas próprias opções
- marcar a opção recomendada com `(Recomendado)` e listá-la primeiro
- incluir opção `Outra` quando fizer sentido
- se escolher `Outra` → solicitar detalhe em seguida (texto livre apenas nessa etapa)
- se resposta ambígua → repetir o mesmo diálogo até seleção explícita
- registrar na análise qual opção foi escolhida

---

## Rodadas de perguntas (fronteira de decisões)

Mapear as dúvidas como uma **árvore de decisões**: cada decisão abre as decisões que dependem dela.

- **Fronteira** = decisões cujos pré-requisitos já estão resolvidos (dá para perguntar agora sem adivinhar respostas ainda não ouvidas).
- Perguntar **toda a fronteira em uma rodada**, numerando as perguntas e incluindo resposta recomendada em cada uma.
- Pergunta cuja resposta depende de outra ainda aberta na mesma rodada vai para uma rodada **posterior**.
- Após cada rodada, recalcular a fronteira com as respostas recebidas e seguir para a próxima.
- Limite prático: até 4 perguntas por rodada; se a fronteira for maior, priorizar as que desbloqueiam mais decisões.

**Fatos são trabalho do agente; decisões são do usuário.**

- NUNCA perguntar ao usuário algo que pode ser descoberto no código, `.agents`, `docs` ou MCP.
- Enquanto um fato estiver sendo levantado, perguntar apenas as decisões que não dependem dele.

Formato da rodada (texto, quando não houver ferramenta nativa de perguntas no target):

```
❓ **P1 — <título>**: <contexto curto da decisão>
  A) <opção> (Recomendado)
  B) <opção>
  C) Outra

❓ **P2 — <título>**: ...
```

- Quando o target oferecer ferramenta nativa de perguntas com opções selecionáveis, usá-la com as perguntas da rodada.
- A fase 1 termina quando a fronteira estiver vazia: todos os ramos visitados, nada assumido silenciosamente.

---

## Modelo de domínio

Aplicar `_shared/base-domain-model.md` em modo **refinamento ativo**:

- usar o vocabulário de `.agents/domain/GLOSSARY.md` em perguntas, abordagens e design
- desafiar termos conflitantes e propor termos canônicos durante as rodadas
- cruzar afirmações do usuário com o código real
- respeitar ADRs existentes; sinalizar explicitamente qualquer abordagem que contradiga um ADR
- ao final de cada fase (e obrigatoriamente na fase 4), listar termos resolvidos e ADRs candidatos e pedir confirmação antes de gravar

---

## Decomposição em sub-projetos

Quando o escopo envolver múltiplos subsistemas independentes (ex.: chat + billing + analytics):

1. listar sub-projetos com relação e ordem sugerida de construção
2. brainstorm **apenas o primeiro** sub-projeto nesta sessão
3. registrar os demais em **Próximos passos** como ciclos futuros (`brainstorm → spec/plan → execute` cada um)
4. NÃO tentar fechar recomendação para o sistema inteiro de uma vez

## Modo mapa (esforço multi-sessão)

Para esforços grandes e nebulosos que **não cabem em uma sessão** (greenfield, feature muito grande), em que o caminho até o destino ainda não é visível. NÃO usar para feature bem delimitada — nesse caso, usar o brainstorm normal ou a decomposição em sub-projetos.

### Ativação

- Propor em diálogo estruturado: `Ativar modo mapa` / `Seguir com brainstorm normal (Recomendado quando cabe em uma sessão)`.
- NUNCA ativar automaticamente.
- O mapa é um artefato salvo: criar arquivos somente após confirmação explícita.

### Artefatos

- Mapa: `.agents/docs/maps/<esforco>/map.md`
- Tickets de decisão: `.agents/docs/maps/<esforco>/tickets/NN-slug.md` (numerados a partir de `01`)

Corpo do mapa (índice, não depósito — a decisão vive no ticket):

```md
## Destino
<como é chegar ao fim deste mapa: spec, decisão ou mudança; 1–2 linhas>

## Notas
<domínio, comandos que toda sessão deve consultar, preferências do esforço>

## Decisões até agora
- [<título do ticket resolvido>](tickets/NN-slug.md): <resumo de uma linha da resposta>

## Ainda não especificado
<névoa: perguntas que se percebem mas ainda não dá para formular com precisão>

## Fora de escopo
<trabalho conscientemente excluído deste esforço, com o motivo>
```

Corpo do ticket:

```md
# NN — <título>

Tipo: pesquisa | protótipo | entrevista | tarefa
Bloqueado por: NN, NN | Nenhum
Status: aberto | em andamento | resolvido

## Pergunta
<a decisão ou investigação que este ticket resolve>

## Resposta
<preenchida ao resolver>
```

### Tipos de ticket

- **pesquisa** (agente sozinho): ler docs, APIs ou fontes locais para obter um fato do qual uma decisão depende; com subagents, um subagent por ticket.
- **protótipo** (com o usuário): artefato barato e descartável para reagir ("como deve parecer/se comportar?").
- **entrevista** (com o usuário, padrão): rodadas de perguntas + modelo de domínio.
- **tarefa** (agente ou usuário): trabalho manual que precisa acontecer antes de uma decisão (ex.: obter acesso, criar conta para avaliar uma API); a resposta registra o que foi feito e fatos resultantes.

O agente NUNCA responde pelo usuário em tickets de entrevista ou protótipo.

### Regras

- **Planejar, não fazer:** cada ticket produz uma decisão, não uma entrega.
- **Um ticket por sessão** (exceto `pesquisa`, que pode rodar em paralelo).
- **Névoa ou ticket?** Se a pergunta já pode ser formulada com precisão (mesmo bloqueada) → ticket; se não → `Ainda não especificado`.
- **Fora de escopo** nunca gradua para ticket; ticket que se revelar fora do destino é fechado e registrado em `Fora de escopo`.
- Referir mapas e tickets **pelo título**, nunca por número solto.
- Fronteira do mapa: tickets `aberto` cujo `Bloqueado por` está todo `resolvido`.

### Invocações

**Mapear** (primeira sessão):

1. definir o **destino** com rodadas de perguntas + modelo de domínio
2. rodada **em largura** sobre todo o espaço, levantando decisões abertas e primeiros passos possíveis
3. se não houver névoa (o caminho já está claro e cabe em uma sessão) → não criar mapa; voltar ao brainstorm normal
4. com confirmação, criar `map.md` e os tickets que já podem ser especificados; ligar `Bloqueado por` em uma segunda passada
5. não resolver tickets nesta sessão (exceto `pesquisa` com subagents)

**Avançar** (sessões seguintes, informando o mapa):

1. carregar `map.md` (visão de baixa resolução)
2. escolher o ticket nomeado pelo usuário ou o primeiro da fronteira; marcar `em andamento` antes de trabalhar
3. resolver conforme o tipo; preencher `## Resposta`; marcar `resolvido`
4. adicionar uma linha em `Decisões até agora`
5. graduar a névoa que ficou especificável em novos tickets; atualizar ou fechar tickets invalidados

### Handoff

- Quando não houver névoa nem tickets abertos → `Pronto para /spec` (a `/spec` em modo síntese consolida as decisões do mapa).
- Se o esforço se revelar pequeno → `Pronto para /plan`.

---

## Trabalho em codebase existente

Antes de propor mudanças:

- explorar estrutura e padrões existentes (Serena quando disponível)
- seguir convenções do projeto
- incluir melhorias **targeted** quando código atual atrapalhar o trabalho (arquivo grande, fronteiras confusas) — justificar e manter escopo focado
- NÃO propor refactoring unrelated ao objetivo atual

### Design para isolamento e clareza

Para cada unidade proposta, responder:

- o que faz?
- como se usa?
- de que depende?

Preferir unidades menores com interfaces claras e responsabilidade única.

---

## Regras

1. Baseie-se em:
   - `.agents` (restrições técnicas)
   - `docs` (objetivos do produto)
   - Serena MCP (quando disponível, para validar o código real)
2. NÃO escolha uma única solução antes da fase 3.
3. NÃO implemente nada.
4. Sempre que necessário:
   - validar suposições com Serena
   - evitar decisões baseadas apenas em contexto estático
5. NÃO avançar para handoff sem aprovação explícita do usuário sobre a recomendação.
6. NÃO invocar `/execute`, `/plan` ou escrever código sem concluir o gate.

---

## Regras específicas

- NÃO assumir arquitetura sem validar no código
- NÃO propor soluções que contradizem padrões existentes
- NÃO pedir confirmação de caminho de arquivos normativos quando o comando já estiver em execução no target ativo
- Se Serena estiver disponível:
  - validar pelo menos uma hipótese no código real
- Se Serena NÃO estiver disponível:
  - avisar limitação na análise
- Aplicar YAGNI:
  - evitar overengineering e escopo não solicitado
- Toda recomendação deve indicar a fonte principal:
  - código real (Serena), docs, ou validação explícita do usuário

---

## Confirmação obrigatória de salvamento (Fase 4)

Antes de marcar status de prontidão, PERGUNTAR ao usuário:

- Deseja salvar o brainstorm para manter os dados documentados?

Apresentar obrigatoriamente opções claras:

- Sim, salvar o brainstorm
- Não, apenas mostrar no chat

Regras:

- NÃO marcar status de prontidão antes da resposta do usuário sobre salvamento
- Fazer a pergunta em diálogo estruturado de opções selecionáveis (não em texto livre)
- Se a resposta estiver ambígua, perguntar novamente usando as mesmas opções
- Registrar na saída a preferência escolhida (salvar ou não salvar)
- Se o usuário escolher salvar, usar destino padrão: `.agents/docs/brainstorm/YYYY-MM-DD-<topico>.md`
- Registrar o path na seção **Próximos passos** quando salvar

---

## Auto-revisão (antes de status de prontidão)

Executar inline antes de marcar `Pronto para /prd`, `Pronto para /spec` ou `Pronto para /plan`:

| Check | O que buscar |
|-------|--------------|
| Placeholders | TBD, TODO, seções incompletas ou vagas |
| Consistência | Contradições entre abordagens, design e recomendação |
| Escopo | Cabe em um único `/plan` ou precisa decomposição em sub-projetos? |
| Ambiguidade | Algum requisito interpretável de duas formas diferentes? |
| Linguagem | Termos usados batem com o glossário? Há termo vago ou sobrecarregado sem resolução? |

Corrigir problemas inline. Não marcar prontidão enquanto houver issue que comprometa o handoff.

---

## Importante

- Se alguma abordagem violar `.agents` → DESCARTAR
- Se houver dúvida → PERGUNTAR (diálogo estruturado)
- NÃO implementar nada
- NÃO inferir comportamento sem evidência

---

## Produza (conteúdo de **Análise**)

Em **Análise**, inclua as subseções `###` aplicáveis à fase atual. Na fase final, incluir **todas** obrigatoriamente:

### Problema

- O que precisa ser resolvido

### Premissas e lacunas

- O que é fato validado
- O que é premissa ainda não validada
- Quais lacunas exigem pergunta ao usuário

### Sub-projetos (quando aplicável)

- Lista de partes independentes, ordem sugerida e qual está em foco nesta sessão

### Possíveis abordagens

- Liste 2 a 5 opções diferentes
- Sempre que possível:
  - basear em padrões reais do código (via Serena)

### Prós e contras

- Para cada abordagem

### Complexidade

- Baixa / Média / Alta (por abordagem ou síntese)

### Design proposto

- Escala por complexidade: poucas frases se simples; até ~300 palavras se complexo
- Cobrir quando aplicável:
  - arquitetura / componentes afetados
  - fluxo de dados
  - tratamento de erros
  - estratégia de testes
  - melhorias colaterais justificadas (se houver)

### Riscos

- Técnicos ou de negócio
- Considerar impacto no código existente

### Critérios de sucesso

- Como medir se a solução atende o objetivo
- Critérios objetivos (funcionais, técnicos e de negócio, quando aplicável)

### Aderência ao projeto

- Compatível com `.agents`?
- Alinhado com `docs`?
- Coerente com o código atual (via Serena)?

### Recomendação

- Melhor opção (com justificativa)
- Handoff sugerido: `/prd`, `/spec` ou `/plan` (com motivo)

### Decisão e rejeitadas

- Opção escolhida e motivo
- Opções descartadas e motivo do descarte

### Confiança na recomendação

- Baixa / Média / Alta

### Linguagem do domínio

- Termos resolvidos (canônico e `_Evitar_`)
- ADRs propostos e gravados (ou motivo para não propor)

### Fase atual

- Indicar fase do processo (ex.: `2/4 — Abordagens`)

### Preferência de salvamento

- Salvar / Não salvar
- Path definido (quando salvar)

---

## Critério de prontidão (DoD)

Só use status `Pronto para /prd`, `Pronto para /spec` ou `Pronto para /plan` se **TODOS** os itens abaixo estiverem atendidos:

- problema definido com escopo claro
- premissas e lacunas explicitadas
- 2 a 5 abordagens comparadas com prós e contras
- design proposto apresentado (escala adequada à complexidade)
- riscos principais identificados
- critérios de sucesso definidos
- recomendação justificada com handoff explícito
- opções rejeitadas registradas com motivo
- auto-revisão concluída (5 checks)
- termos de domínio resolvidos registrados ou explicitamente adiados
- preferência de salvamento registrada
- aprovação explícita do usuário para seguir ao próximo comando

---

## Orquestração com subagents

Aplicar `_shared/base-subagents.md`. Somente quando a decisão do `/workflow` for `Orquestração: Com subagents`:

- **Levantamento de fatos:** enviar subagents de exploração somente leitura para fatos que as rodadas precisam (estrutura do código, padrões existentes, implementações similares, docs externas)
- enquanto rodam, perguntar ao usuário apenas as decisões da fronteira que não dependem desses fatos
- verificar os achados no código antes de usá-los em abordagens ou design
- **Modo mapa:** tickets do tipo `pesquisa` podem ser resolvidos por subagents em paralelo (um por ticket), sem decidir nada pelo usuário
- decisões, recomendações e gates continuam no contexto principal

Sem subagents → executar tudo no contexto principal.

---

## Formato obrigatório de saída

Responda **sempre** com estes quatro títulos `##`, **nesta ordem** e **com estes nomes exatos**:

1. **Status** — usar apenas um valor entre:
   - `Em exploração (fase 1/4)`
   - `Em exploração (fase 2/4)`
   - `Em exploração (fase 3/4)`
   - `Em exploração (fase 4/4)`
   - `Aguardando resposta`
   - `Bloqueado`
   - `Pronto para /prd`
   - `Pronto para /spec`
   - `Pronto para /plan`
   - `Mapa atualizado` (modo mapa: sessão encerrada com o mapa salvo)
2. **Análise** — conteúdo principal; use apenas `###` para subdividir (ver lista acima).
3. **Problemas** — violações a `.agents`, lacunas de contexto, riscos inaceitáveis, violação de HARD-GATE; se não houver: **Nenhum**.
4. **Próximos passos** — ex.: perguntas ao usuário (diálogo estruturado), rodar `/prd`, `/spec` ou `/plan`, salvar artefato; aguardar confirmação explícita antes de handoff (**sempre** a última seção `##` da resposta).

Não omita seções. Não renomeie os títulos.
