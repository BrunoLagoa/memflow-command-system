---
description: Não é um comando executável. Base compartilhada de orquestração com ou sem subagents.
license: MIT
hidden: true
metadata:
  author: BrunoCastro
  version: "1.0.0"
---

# Base comum de orquestração com subagents (referência normativa)

Aplicar este bloco nos comandos que podem delegar trabalho a subagents (`/workflow`, `/brainstorm`, `/spec`, `/plan`, `/execute`, `/debug`, `/refactor`, `/review-code`, `/retro`).

Objetivo: permitir paralelismo e isolamento de contexto **opcionais**, sem perder previsibilidade, gates e confirmações do Memflow.

---

## Modos de orquestração

- **Sem subagents (padrão):** todo o trabalho acontece no contexto principal, em sequência. Mais barato e previsível.
- **Com subagents:** tarefas bem delimitadas são enviadas a subagents (janela de contexto própria), em paralelo quando independentes, e o agente principal consolida os relatórios.

---

## Quem decide (CRÍTICO)

- O modo é decidido no `/workflow`, **a cada nova tarefa**, em diálogo estruturado (ver Etapa 5.1 do `/workflow`).
- O padrão é **Sem subagents**.
- A decisão vale para os comandos seguintes da mesma tarefa e deve constar na `### Estratégia` do `/workflow` como `Orquestração: Com subagents | Sem subagents`.
- Comandos posteriores leem essa decisão; na ausência dela → operar **Sem subagents**.
- O usuário pode trocar o modo a qualquer momento pedindo explicitamente; nesse caso, registrar a troca na `## Análise`.

---

## Capacidade do target

A ferramenta de subagent depende do target ativo (ver seção *Subagents* em `_shared/target-adapter.md`):

| Target | Ferramenta | Observação |
| ------ | ---------- | ---------- |
| `claude` | Agent (subagents) | múltiplas chamadas na mesma mensagem rodam em paralelo |
| `opencode` | Task (`general`, `explore`) | `explore` é somente leitura; `general` não cria novos subagents |
| `cursor` | Task (subagents) | múltiplas chamadas na mesma mensagem rodam em paralelo; subagents customizados em `.cursor/agents/` |
| `vscode` | `runSubagent` (alias `agent`) | disponível no modo Agent do Copilot Chat |

Se a ferramenta não estiver disponível na sessão (modo sem ferramentas, permissão negada, modo Ask, versão antiga):

- NÃO bloquear
- operar **Sem subagents** (fallback sequencial)
- avisar explicitamente na resposta: `Orquestração: Sem subagents (fallback — ferramenta indisponível)`

---

## Usos permitidos (lista fechada)

1. **Levantamento de fatos (somente leitura):** explorar código, docs ou fontes externas para responder uma pergunta factual. Usado por `/brainstorm`, `/spec`, `/plan`, `/debug`, `/refactor`, `/retro`.
2. **Revisão paralela:** eixos independentes de revisão que não devem contaminar o contexto um do outro. Usado por `/review-code`.
3. **Implementação da fronteira:** tarefas `[P]` da fronteira do plano, isoladas entre si. Usado por `/execute`.
4. **Design em paralelo:** formas alternativas e radicalmente diferentes para uma mesma interface. Usado por `/refactor`.

Qualquer outro uso → NÃO delegar; executar no contexto principal.

---

## Regras para o subagent (OBRIGATÓRIO)

Todo brief de subagent deve:

- ter **escopo fechado**: uma pergunta ou uma tarefa, com critério de conclusão verificável
- comunicar por **ponteiros de contexto** (paths de spec, plano, brainstorm, ADRs, commits) em vez de copiar conteúdo
- informar limite de resposta (ex.: até 400 palavras) e o formato do relatório
- declarar o que é proibido ao subagent:
  - fazer perguntas ao usuário (decisões continuam com o agente principal e o usuário)
  - executar o próximo comando do fluxo
  - escrever em `.agents/memory/` ou `.agents/domain/`
  - atualizar o plano salvo (o agente principal é o **único escritor** do plano)
  - fazer push ou alterar branches compartilhadas (commit só é permitido na branch própria da tarefa, quando isolada em worktree pelo `/execute`)

---

## Regras para o agente principal (OBRIGATÓRIO)

- Enviar subagents independentes **na mesma mensagem** para que rodem em paralelo.
- Limite prático: até 4 subagents simultâneos por rodada.
- Enquanto um levantamento de fatos roda, seguir apenas com o que não depende dele.
- **Não confiar cegamente:** verificar os relatórios (rodar o teste/comando citado, abrir o trecho de código citado) antes de usá-los como evidência.
- Consolidar resultados e decisões no próprio contexto e na saída do comando.
- HARD-GATEs, gates de salvamento e confirmações explícitas continuam valendo integralmente.
- Escolha de modelo dos subagents segue `model-policy.md`: econômico para levantamento de fatos; mesmo nível da tarefa para implementação e revisão.

---

## Saída

Todo comando que aplicar este bloco registra na `## Análise`:

- `Orquestração: Com subagents / Sem subagents / Sem subagents (fallback)`
- quando houver subagents: lista curta do que foi delegado e o resultado consolidado

---

## Regra de precedência

- Este arquivo define o padrão comum de orquestração.
- Comandos podem restringir (nunca ampliar) os usos permitidos.
- Invariantes não sobrescrevíveis:
  - padrão é Sem subagents
  - decisão do modo pertence ao `/workflow` (ou a pedido explícito do usuário)
  - ausência de ferramenta → fallback sequencial com aviso, sem bloquear
  - subagents não decidem, não perguntam ao usuário e não escrevem memória, domínio ou plano
  - gates e confirmações do Memflow não são contornados por subagents
