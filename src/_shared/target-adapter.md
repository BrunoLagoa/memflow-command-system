---
description: Não é um comando executável. Adaptador de target para resolução normativa no OpenCode.
license: MIT
hidden: true
metadata:
  author: BrunoCastro
  version: "1.0.0"
---

# Adaptador de target (OpenCode)

Aplicar este adaptador quando o target ativo for `opencode`.

## Resolução de caminhos normativos (obrigatória)

- Para arquivos normativos do sistema, usar os caminhos oficiais por escopo:
  - `~/.config/opencode/commands/memflow/...` (global)
  - `.opencode/commands/memflow/...` (local)
- Nunca resolver:
  - `model-policy.md`
  - `_shared/*.md`
  relativo ao projeto aberto.

## Ausência de arquivo oficial

- Se o arquivo não for encontrado em nenhum caminho oficial:
  - reportar ausência
  - NÃO usar fallback

## Precedência

- Este adaptador define a resolução para `opencode`.
- Em caso de conflito com regra específica do comando:
  - prevalece o comando específico.
