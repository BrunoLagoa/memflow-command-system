---
description: Não é um comando executável. Adaptador de target para resolução normativa no OpenCode.
license: MIT
hidden: true
metadata:
  author: BrunoCastro
  version: "1.2.0"
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

## Detecção automática de escopo (obrigatória)

- Determinar escopo de instalação antes de pedir qualquer confirmação ao usuário.
- Ordem obrigatória:
  1. Detectar o diretório do comando em execução (`.../commands/memflow/<comando>.md`) e usar este diretório como raiz normativa.
  2. Se a raiz detectada estiver em `~/.config/opencode/commands/memflow`, classificar como **global**.
  3. Se a raiz detectada estiver em `.opencode/commands/memflow`, classificar como **local**.
  4. Resolver `_shared/*.md` e `model-policy.md` de forma relativa à raiz detectada.
- Só tentar descoberta por caminhos oficiais (`global -> local`) quando o caminho do comando em execução não estiver disponível.
- Não solicitar ao usuário confirmação de localização de arquivos normativos quando a detecção automática for possível.

## Ausência de arquivo oficial

- Se o arquivo não for encontrado em nenhum caminho oficial:
  - reportar ausência
  - NÃO usar fallback

## Precedência

- Este adaptador define a resolução para `opencode`.
- Comandos podem estender apenas regras operacionais de leitura.
- Invariantes não sobrescrevíveis:
  - detecção automática de escopo quando houver comando ativo
  - resolução normativa relativa à raiz detectada
  - ausência em caminho oficial sem fallback fora do adaptador
