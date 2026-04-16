# Changelog

Todas as mudanças relevantes deste projeto serão documentadas neste arquivo.

O formato segue o padrão [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/) e o versionamento segue [Semantic Versioning](https://semver.org/lang/pt-BR/).

## [1.1.7] - 2026-04-16

### Corrigido
- `src/model-policy.md`: frontmatter corrigido para o contexto correto de política de modelos (`description`, `hidden` e metadados), alinhando o arquivo ao padrão das bases compartilhadas não executáveis.

## [1.1.6] - 2026-04-16

### Alterado
- `README.md`: seção **Instalação não interativa** em macOS/Linux atualizada para one-liners remotos com `curl -fsSL ... | bash -s -- install`, tanto no escopo `global` quanto `local`, mantendo `--target opencode`.

## [1.1.5] - 2026-04-16

### Alterado
- `README.md`: seção **Remover instalação** refatorada para adotar o mesmo padrão operacional de instalação/update, com exemplos remotos (`curl -fsSL ...` e `powershell -ExecutionPolicy Bypass -Command ...`) para escopos global e local em macOS/Linux e PowerShell.

### Removido
- Exemplos locais legados de `uninstall` via `memflowctl` e execução direta de scripts no repositório, em favor de one-liners remotos padronizados.

## [1.1.4] - 2026-04-16

### Alterado
- `scripts/install.sh` e `scripts/install.ps1`: mensagens de atualização passaram a exibir versão instalada e versão disponível no mesmo texto (`Atual: ... | Disponível: ...`) para melhorar clareza operacional.
- `scripts/install.sh` e `scripts/install.ps1`: mensagem de estado atualizado simplificada para `MEMFLOW já está atualizado (...)`.

### Removido
- Linha de saída `Próximos passos: /context e /workflow` após instalação concluída, reduzindo ruído no output dos instaladores.

## [1.1.3] - 2026-04-16

### Adicionado
- Teste de regressão do instalador em `scripts/tests/test-install-regression.sh`, cobrindo cenários de `update`/`uninstall` sem instalação e validação de código de saída `2`.
- Workflow de CI `.github/workflows/install-regression.yml` para executar automaticamente a regressão do instalador em `push`, `pull_request` e execução manual.

### Alterado
- Organização de testes em `scripts/tests/`, removendo o caminho legado `scripts/test/`.
- `README.md`: documentação de comportamento para `update` sem instalação prévia (modo interativo vs não interativo) e semântica de erro no `uninstall`.

### Corrigido
- `scripts/install.sh`: `update` agora informa ausência de instalação e, em modo interativo, pergunta se deve iniciar uma nova instalação; em modo não interativo, retorna erro explícito com código `2`.
- `scripts/install.sh`: `uninstall` agora retorna erro explícito com código `2` quando não houver instalação no escopo solicitado.
- `scripts/install.ps1`: alinhamento de `update`/`uninstall` com comportamento consistente de ausência de instalação, incluindo erro explícito com código `2` e fallback interativo para nova instalação no `update`.

## [1.1.2] - 2026-04-16

### Adicionado
- `README.md`: subseção **Escopo global vs local** (`--scope` / `--project-dir`), remissões em instalação não interativa, `memflowctl`, desinstalação e destinos; exemplos de `update` remoto com descoberta automática de escopo (sem `--scope` / `-Scope`).

### Corrigido
- `update` em `scripts/install.sh`: quando o usuário não passa `--scope`, o escopo passa a ser inferido do manifest (`.memflow-install.json`) em vez de ficar preso ao padrão `global`.
- `update` em `scripts/install.ps1`: busca do manifest quando `-Scope` não é informado; escopo e SO efetivos derivados do manifest; mensagem clara quando não existe instalação MEMFLOW.

## [1.1.1] - 2026-04-16

### Adicionado
- Arquivo `CHANGELOG.md` com histórico consolidado das versões publicadas.
- Registro retroativo das mudanças de `v1.0.0` e `v1.1.0` para manter rastreabilidade de releases.

### Alterado
- Processo de release passa a incluir atualização obrigatória do changelog.

## [1.1.0] - 2026-04-16

### Adicionado
- Ação `check` nos instaladores `scripts/install.sh` e `scripts/install.ps1` para consultar atualização sem alterar a instalação.
- Cache de 24h para consulta de versão mais recente, com saída silenciosa quando não houver update.
- Entrypoints `scripts/memflowctl` e `scripts/memflowctl.ps1` para executar `install`, `update`, `uninstall` e `check` fora do diretório do repositório.
- Orientação de fluxo em `src/review.md` e fallback em `src/execute.md` para check silencioso de versão ao final.

### Alterado
- Mensagens de update passam a sugerir comando desacoplado (`memflowctl`) com `--non-interactive` e `scope` correto.
- `README.md` atualizado com exemplos completos de operação `global` e `local` para instalação, update, check e uninstall.

### Corrigido
- `update`/`uninstall` no escopo local agora exigem `--project-dir` (`-ProjectDir` no PowerShell) quando necessário, reduzindo risco operacional.
- Fluxo de update evita tentativa de atualização quando a versão instalada já é a mais recente.

### Removido
- `logo.png` na raiz do repositório (asset obsoleto).

## [1.0.0] - 2026-04-16

### Adicionado
- Estrutura inicial do `memflow-command-system`.
- Workflow base por comandos em `src/` para contexto, decisão, execução e validação (`/context`, `/workflow`, `/execute`, `/review`, `/review-enforce-rules`).
- Instalador cross-platform com fluxo interativo para Bash e PowerShell.

### Alterado
- Wizard do instalador com prompts e onboarding refinados.
- Seção de roadmap da documentação ampliada.

[1.1.7]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.6...v1.1.7
[1.1.6]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.5...v1.1.6
[1.1.5]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.4...v1.1.5
[1.1.4]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.3...v1.1.4
[1.1.3]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.2...v1.1.3
[1.1.2]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.1...v1.1.2
[1.1.1]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/BrunoLagoa/memflow-command-system/releases/tag/v1.0.0
