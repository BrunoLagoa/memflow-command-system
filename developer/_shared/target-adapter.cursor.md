---
description: Não é um comando executável. Adaptador de target para comandos gerados no Cursor.
license: MIT
hidden: true
metadata:
  author: BrunoCastro
  version: "1.0.0"
---

# Adaptador de target (Cursor)

Aplicar este adaptador quando o target ativo for `cursor`.

## Resolução normativa

- Em comandos gerados para Cursor, as bases normativas `_shared/*.md` devem ser tratadas como conteúdo local injetado no próprio arquivo do comando.
- Em comandos gerados para Cursor, `model-policy.md` também vem como bloco injetado no mesmo arquivo do comando (não existe comando separado `model-policy` na instalação Cursor).
- Não aplicar resolução por caminhos globais/locais de OpenCode.
- `model-policy.md` deve ser interpretado no contexto do comando gerado (texto completo já presente no arquivo quando a linha injetável foi expandida pelo instalador).

## Layout de instalação

- Os comandos são instalados localmente por projeto em `<projeto>/.cursor/commands/memflow/<comando>.md`.
- O frontmatter é removido pelo instalador; a descrição do comando aparece como citação no topo do arquivo.
- Não há separação global/local: a instalação é sempre local ao projeto.

## Ausência de conteúdo

- Se uma base normativa necessária não estiver presente no comando gerado:
  - reportar ausência
  - bloquear execução crítica

## Subagents

- Ferramenta de subagent neste target: **Task** (subagents do Cursor).
- Várias chamadas Task na mesma mensagem rodam em paralelo; subagents customizados podem existir em `.cursor/agents/`.
- Levantamento de fatos → subagent de exploração somente leitura quando disponível; implementação e revisão → subagent de uso geral.
- Disponibilidade, usos permitidos e fallback seguem `_shared/base-subagents.md`.
- Se a ferramenta não estiver disponível na sessão → operar sem subagents (fallback sequencial) e avisar.

## Precedência

- Este adaptador define a resolução para `cursor`.
- Comandos podem estender regras operacionais sem remover os requisitos deste adaptador.
- Invariantes não sobrescrevíveis:
  - `_shared/*.md` devem estar injetados no comando
  - `model-policy.md` deve estar injetado no comando (mesmo mecanismo que `_shared`)
  - ausência de base normativa necessária bloqueia execução crítica
