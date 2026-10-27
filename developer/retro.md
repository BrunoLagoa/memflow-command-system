---
name: retro
description: Retrospectiva da sessão focada no ambiente do agente (não no código) — analisa a sessão e sugere melhorias em navegação, checagens automáticas, padrões de código, arquivos de instrução (AGENTS.md/CLAUDE.md), economia de ferramentas e acesso a informação, ordenadas por severidade. Erros mecânicos viram checagens determinísticas; julgamentos viram padrões para o revisor. Não aplica mudanças; aguarda confirmação. Saída: Status, Análise, Problemas e Próximos passos.
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
- `_shared/base-subagents.md`
- `_shared/target-adapter.md`
- `model-policy.md`

---

## Objetivo

Melhorar o **ambiente** em que o agente trabalha, para que as próximas sessões comecem melhores:

- encontrar o que custou tempo, tokens ou retrabalho na sessão
- propor mudanças no ambiente (não no código de produto)
- priorizar pelas mais severas

---

## Integração com sistema

Este comando:

- é opcional e roda ao fim de uma tarefa (após `/review`, `/review-code` ou `/memory-save`), especialmente quando a sessão saiu do trilho
- também pode rodar depois de um `/debug`, perguntando o que teria evitado o bug
- NÃO implementa as melhorias: as escolhidas seguem para `/workflow` → `/plan` ou `/execute`
- NÃO substitui `/memory-save`: decisões do **projeto** vão para memória; melhorias do **ambiente** ficam aqui

---

## Uso de modelo (ALINHADO AO MODEL-POLICY)

- modelo intermediário por padrão
- escalar apenas quando a sessão analisada for longa ou complexa

---

## Fontes primárias

Analisar a sessão indicada pelo usuário; se não indicada, a sessão atual:

- o histórico da conversa atual (fonte primária preferencial — rodar `/retro` **antes** de limpar o contexto)
- `.agents/memory/session-memory.md` e `.agents/memory/quality-metrics.md` (quando existirem)
- logs de sessão do target, quando o usuário apontar o caminho
- arquivos de instrução e checagens do repositório: `AGENTS.md`, `CLAUDE.md`, `CODING_STANDARDS.md`, `CONTRIBUTING.md`, `.agents/rules/**`, scripts de lint/test, configs de pre-commit e workflows de CI

Antes de propor uma checagem nova, ler os comandos de checagem existentes (scripts `lint`/`check`/`test`, CI): uma checagem que já existe mas está desconectada ou quebrada é o achado, não uma reinvenção.

---

## Categorias de candidatos

- **Navegação:** o agente demorou para achar arquivos ou informação? Há dependências ocultas entre arquivos? Um ponteiro de navegação ajudaria?
- **Checagens automáticas:** algum erro do agente poderia ter sido pego por lint, tipagem, teste ou verificador de arquivos? Repositório sem guardrail (sem pre-commit e sem CI rodando lint/typecheck/test) é achado por si só.
- **Padrões de código:** o revisor deveria ganhar uma regra nova, ou ter uma regra removida/clarificada?
- **Arquivos de instrução:** `AGENTS.md`/`CLAUDE.md` têm instruções que deveriam virar padrão de código ou checagem automática? Estão grandes demais?
- **Economia de ferramentas:** houve chamadas caras que poderiam ser simplificadas? Alguma ferramenta (CLI, MCP) é ineficiente em tokens?
- **No-ops:** instruções que não mudam o comportamento do agente e só ocupam contexto.
- **Acesso a informação:** faltou informação crucial (logs do servidor, acesso somente leitura a serviços externos)?

---

## Regras de classificação (OBRIGATÓRIO)

- **Violação mecânica** (padrão sintático fixo, API proibida, forma de import, regra de local de arquivo) → **checagem determinística** (regra no linter do repo, hook de pre-commit ou job de CI, o que for mais barato). Preferir construir a checagem a escrever a regra.
- **Julgamento** (consistência entre arquivos, "segue o estilo ao redor") → **padrão de código** em `CODING_STANDARDS.md` (ou documento equivalente do repo), lido pelo revisor.
- O revisor (`/review-code`) impõe padrões; o implementador (`/execute`) tem a maior pressão de contexto e não deve carregar regras que o revisor pode cobrar.
- `AGENTS.md`/`CLAUDE.md` vão para o contexto de todo agente: usar com parcimônia, de preferência só com ponteiros de navegação.
- Antes de criar um documento novo, procurar um existente.

---

## Orquestração com subagents

Aplicar `_shared/base-subagents.md`. Somente quando a decisão do `/workflow` for `Orquestração: Com subagents`:

- **Levantamento de fatos:** subagents somente leitura podem varrer logs de sessão longos e os arquivos de instrução/checagem do repo em paralelo, reportando evidências
- a classificação, a priorização e a proposta continuam no contexto principal

Sem subagents → analisar tudo no contexto principal.

---

## Regras

- NÃO alterar código, configs, `AGENTS.md`/`CLAUDE.md` ou CI neste comando
- NÃO propor mudança sem evidência da sessão (citar o momento ou a chamada que motivou)
- NÃO duplicar o que já foi registrado por `/memory-save`
- Ordenar candidatos por severidade: **Alta** (causou erro ou retrabalho relevante) → **Média** (custou tempo/tokens) → **Baixa** (melhoria de conforto)
- Mascarar segredos em qualquer trecho citado

---

## Formato obrigatório de saída

## Status

- Retro concluída / Aguardando dados / Bloqueado

---

## Análise

### Sessão analisada

- fonte (sessão atual, log indicado) e resumo do que aconteceu

### Candidatos (por severidade)

Para cada candidato:

- **Severidade:** Alta / Média / Baixa
- **Categoria:** Navegação / Checagens automáticas / Padrões de código / Arquivos de instrução / Economia de ferramentas / No-ops / Acesso a informação
- **Evidência:** o que aconteceu na sessão
- **Proposta:** a mudança no ambiente
- **Tipo de mudança:** checagem determinística / padrão de código / ponteiro de navegação / ferramenta / remoção de instrução

### Orquestração

- Com subagents / Sem subagents / Sem subagents (fallback)

---

## Problemas

- limitações da análise (sessão compactada, logs indisponíveis)

Se não houver:
→ Nenhum

---

## Próximos passos

- Escolher quais candidatos implementar (diálogo estruturado)
- Seguir para `/workflow` com os candidatos escolhidos
- Aguardar confirmação explícita do usuário antes de qualquer novo comando
