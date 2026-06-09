---
description: Não é um comando executável. Adaptador de target para comandos gerados no Claude Code.
license: MIT
hidden: true
metadata:
  author: BrunoCastro
  version: "1.0.0"
---

# Adaptador de target (Claude Code)

Aplicar este adaptador quando o target ativo for `claude`.

## Resolução normativa

- Em comandos gerados para Claude Code, as bases normativas `_shared/*.md` devem ser tratadas como conteúdo local injetado no próprio arquivo do comando.
- Em comandos gerados para Claude Code, `model-policy.md` também vem como bloco injetado no mesmo arquivo do comando (não existe comando separado `model-policy` na instalação Claude Code).
- Não aplicar resolução por caminhos globais/locais de OpenCode.
- `model-policy.md` deve ser interpretado no contexto do comando gerado (texto completo já presente no arquivo quando a linha injetável foi expandida pelo instalador).

## Layout de instalação

- Os comandos são instalados localmente por projeto em `<projeto>/.claude/commands/memflow/<comando>.md`.
- Cada arquivo é um slash command de projeto; o nome do arquivo é o nome do comando (ex.: `context.md` é invocado como `/context`).
- A subpasta `memflow` aparece como namespace `(project:memflow)` no `/help` e não altera o nome do comando.
- Não há separação global/local: a instalação é sempre local ao projeto.

## Ausência de conteúdo

- Se uma base normativa necessária não estiver presente no comando gerado:
  - reportar ausência
  - bloquear execução crítica

## Precedência

- Este adaptador define a resolução para `claude`.
- Comandos podem estender regras operacionais sem remover os requisitos deste adaptador.
- Invariantes não sobrescrevíveis:
  - `_shared/*.md` devem estar injetados no comando
  - `model-policy.md` deve estar injetado no comando (mesmo mecanismo que `_shared`)
  - ausência de base normativa necessária bloqueia execução crítica
