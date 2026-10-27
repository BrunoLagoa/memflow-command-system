---
description: Não é um comando executável. Adaptador de target para prompts gerados no VSCode.
license: MIT
hidden: true
metadata:
  author: BrunoCastro
  version: "1.3.0"
---

# Adaptador de target (VSCode)

Aplicar este adaptador quando o target ativo for `vscode`.

## Resolução normativa

- Em prompts gerados para VSCode, as bases normativas `_shared/*.md` devem ser tratadas como conteúdo local injetado no próprio prompt.
- Em prompts gerados para VSCode, `model-policy.md` também vem como bloco injetado no mesmo arquivo do prompt (não existe prompt separado `memflow.model-policy` na instalação VS Code).
- Não aplicar resolução por caminhos globais/locais de OpenCode.
- `model-policy.md` deve ser interpretado no contexto do prompt gerado para VSCode (texto completo já presente no prompt quando a linha injetável foi expandida pelo instalador).

## Ausência de conteúdo

- Se uma base normativa necessária não estiver presente no prompt gerado:
  - reportar ausência
  - bloquear execução crítica

## Subagents

- Ferramenta de subagent neste target: **`runSubagent`** (alias `agent`), disponível no modo **Agent** do Copilot Chat.
- No modo Ask ou sem a ferramenta habilitada no seletor de ferramentas → fallback sequencial.
- Agentes customizados (`.agent.md`) podem ser usados como subagents quando não estiverem com `disable-model-invocation: true`.
- Disponibilidade, usos permitidos e fallback seguem `_shared/base-subagents.md`.
- Se a ferramenta não estiver disponível na sessão → operar sem subagents (fallback sequencial) e avisar.

## Precedência

- Este adaptador define a resolução para `vscode`.
- Comandos podem estender regras operacionais sem remover os requisitos deste adaptador.
- Invariantes não sobrescrevíveis:
  - `_shared/*.md` devem estar injetados no prompt
  - `model-policy.md` deve estar injetado no prompt (mesmo mecanismo que `_shared`)
  - ausência de base normativa necessária bloqueia execução crítica
