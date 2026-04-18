# Changelog

Todas as mudanças relevantes deste projeto serão documentadas neste arquivo.

O formato segue o padrão [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/) e o versionamento segue [Semantic Versioning](https://semver.org/lang/pt-BR/).

## [1.1.18] - 2026-04-18

### Alterado
- `src/_shared/base-output.md`: regra explícita de que `## Próximos passos` é o último `##` da resposta e que a continuidade do fluxo não usa linhas `Próximo passo:` fora dessa seção.
- `src/review-enforce-rules.md`: `## Formato obrigatório de saída` passa ao fim do arquivo (após base de validação, verificações e critérios), para o template normativo encerrar com **Próximos passos** como última seção descrita.
- `src/brainstorm.md`: `## Produza` antecede `## Formato obrigatório de saída`, evitando qualquer `##` adicional após a definição do bloco de saída.
- `src/context.md`: norma de continuidade apenas em `## Próximos passos`; remoção de bullets redundantes em ultra-light, Resumo e Estado do fluxo.
- `src/execute.md`: bloqueio por ausência de plano descreve a continuidade via seção **Próximos passos** em vez de bullet `Próximo passo:`.

## [1.1.17] - 2026-04-17

### Alterado
- `src/_shared/base-output.md`: `## Regras de uso` antecede o bloco Status → Análise → Problemas → Próximos passos, deixando `## Próximos passos` como última seção do template normativo.
- Comandos em `src/*.md`: alinhamento do formato de saída para que `## Próximos passos` seja sempre a última seção `##` da resposta — metas (`## Importante`, `## Boas práticas`, `## Regras` onde aplicável) e critérios passam a preceder `## Formato obrigatório de saída`; onde havia conteúdo de saída após Próximos passos (ex.: modelo no plano, persistência/bloqueios no execute), esse conteúdo foi reordenado para antes de `## Próximos passos`.
- `src/review-enforce-rules.md`: removida duplicação de modelo de `## Problemas` / `## Próximos passos` no fim do arquivo; detalhe incorporado ao bloco de formato obrigatório.
- `src/brainstorm.md`: `## Regras específicas` e `## Importante` antes do formato; `## Final` removido com orientação fundida em **Próximos passos**.

## [1.1.16] - 2026-04-17

### Alterado
- `src/workflow.md`: no formato obrigatório de saída, a seção `## Próximos passos` passa a aparecer após `## Estratégia de execução` (depois de modelo e estratégia, antes de `## Regras`).

## [1.1.15] - 2026-04-17

### Alterado
- `src/context.md` e `src/memory-init.md`: referências normativas em lazy load passaram a usar resolução pelo target ativo via `_shared/target-adapter.md`, removendo caminho hardcoded de OpenCode.
- `src/memory-init.md`: seção "Sistema de comandos" atualizada para descrever diretório normativo de forma agnóstica ao target.

## [1.1.14] - 2026-04-17

### Alterado
- `src/_shared/base-preconditions.md` e `src/_shared/base-degraded-mode.md`: regras comportamentais tornadas agnósticas de target, com resolução delegada ao adaptador.
- `src/_shared/target-adapter.md` e `src/_shared/target-adapter.vscode.md`: novos adaptadores de resolução normativa por target (`opencode` e `vscode`).
- `src/*.md`: referências normativas comuns atualizadas para usar `_shared/base-*` + `_shared/target-adapter.md`, removendo paths OpenCode hardcoded dos comandos.
- `src/execute.md`, `src/plan.md`, `src/review.md`, `src/review-enforce-rules.md`, `src/refactor.md`, `src/debug.md` e `src/workflow.md`: referências de `model-policy.md` migradas para resolução por target via adaptador compartilhado.
- `scripts/installers/bash/targets/vscode.sh` e `scripts/installers/powershell/targets/vscode.ps1`: renderização de prompts VSCode atualizada para injetar `target-adapter.vscode.md` quando houver referência a `target-adapter.md`.
- `README.md` e `README.pt-BR.md`: documentação de `_shared` e do fluxo de geração VSCode atualizada para refletir a arquitetura núcleo + adaptador de target.

## [1.1.13] - 2026-04-17

### Alterado
- `scripts/install.sh` e `scripts/install.ps1`: target `vscode` agora usa instalação única por projeto gerando apenas prompt files em `.github/prompts` (sem geração de `.github/agents`), sem divisão entre escopos `global` e `local`.
- `scripts/install.sh` e `scripts/install.ps1`: para `vscode`, referências de caminhos `.../_shared/...` nos comandos agora são substituídas pelo conteúdo real das bases compartilhadas durante a geração dos `.prompt.md`.
- `scripts/install.sh` e `scripts/install.ps1`: descoberta sem escopo agora permite filtrar por target explícito (`--target` / `-Target`) e mantém comportamento padrão quando não informado.
- `scripts/install.sh` e `scripts/install.ps1`: arquitetura interna refatorada para módulos por domínio/target/ação (`scripts/installers/bash/*` e `scripts/installers/powershell/*`), mantendo a interface de CLI.
- `scripts/installers/bash/actions.sh` e `scripts/installers/powershell/actions.ps1`: ações passaram a atuar como dispatcher fino, delegando a implementação para módulos dedicados por target.
- `scripts/installers/bash/targets/*` e `scripts/installers/powershell/targets/*`: separação forte de `opencode` e `vscode` com arquivos independentes por target.
- `scripts/memflowctl` e `scripts/memflowctl.ps1`: download remoto atualizado para buscar também os módulos do instalador, preservando execução via bootstrap remoto.
- `scripts/manifest.schema.json`: `target.enum` ampliado para aceitar `vscode`.
- `scripts/tests/test-install-regression.sh`: cobertura atualizada para fluxo único de `vscode` (install/update/check/uninstall e ausência de instalação), garantindo que não exista instalação global para esse target.
- `README.md` e `README.pt-BR.md`: documentação atualizada para refletir o modelo único de instalação no `vscode`.

## [1.1.12] - 2026-04-17

### Alterado
- `src/execute.md` e `src/review.md`: check silencioso de atualização passou a orientar somente comandos remotos (`install.sh`/`install.ps1`) para eliminar dependência de `memflowctl` no ambiente.

## [1.1.11] - 2026-04-17

### Alterado
- `src/workflow.md`: saída obrigatória de recomendação de modelo passou a incluir nível, modelo principal, alternativas do mesmo nível e regra explícita de fallback por disponibilidade.
- `src/model-policy.md`: política de seleção operacional atualizada para formalizar o padrão "1 modelo principal + alternativas do mesmo nível", com fallback intra-nível antes de escalada.
- `README.md` e `README.pt-BR.md`: documentação de diferenciais e arquitetura ajustada para refletir seleção de modelo com principal e alternativas.

## [1.1.10] - 2026-04-16

### Corrigido
- `src/*.md`: atualização das referências normativas para o novo namespace `commands/memflow`, incluindo `_shared` e `model-policy.md`.
- `src/*.md`: instruções de resolução de caminhos ajustadas para considerar explicitamente os dois escopos oficiais (`global` e `local`) sem fallback fora dos caminhos definidos.

## [1.1.8] - 2026-04-16

## [1.1.9] - 2026-04-16

### Adicionado
- `README.pt-BR.md`: variante em português com seletor de idioma e paridade estrutural com a versão padrão.
- `docs/SDLC.pt-BR.md`: variante em português do guia SDLC com seletor de idioma e links cruzados.
- `AGENTS.md`: instruções compactas para sessões OpenCode, com comandos de verificação, layout de alto valor e quirks do instalador.

### Alterado
- `README.md`: passou a ser a versão padrão em inglês, com seletor de idioma e seção de documentação apontando para SDLC em inglês e português.
- `docs/SDLC.md`: passou a ser a versão padrão em inglês, mantendo estrutura e comandos do conteúdo original.

### Adicionado
- `README.md`: seção **Check de versão** documentada com comando geral (macOS/Linux e PowerShell) logo após **Atualizar para nova versão**.
- `scripts/tests/test-install-regression.sh`: cobertura para `check` sem escopo nos cenários com instalações em `global`+`local` e `global-only`.

### Alterado
- `scripts/install.sh` e `scripts/install.ps1`: `update` sem `--scope` / `-Scope` agora processa automaticamente os dois escopos (`global` e `local`) quando ambos tiverem instalação detectada por manifest.
- `scripts/install.sh` e `scripts/install.ps1`: `uninstall` sem `--scope` / `-Scope` agora remove automaticamente os dois escopos (`global` e `local`) quando ambos estiverem instalados.
- `scripts/install.sh` e `scripts/install.ps1`: `check` sem `--scope` / `-Scope` agora avalia automaticamente os dois escopos (`global` e `local`) quando ambos tiverem instalação detectada por manifest.
- `README.md`: documentação de descoberta automática em `update`/`check`/`uninstall` atualizada para refletir execução em múltiplos escopos com comando geral único.

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

[1.1.18]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.17...v1.1.18
[1.1.17]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.16...v1.1.17
[1.1.16]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.15...v1.1.16
[1.1.15]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.14...v1.1.15
[1.1.14]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.13...v1.1.14
[1.1.13]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.12...v1.1.13
[1.1.12]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.11...v1.1.12
[1.1.11]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.10...v1.1.11
[1.1.10]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.9...v1.1.10
[1.1.9]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.8...v1.1.9
[1.1.8]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.7...v1.1.8
[1.1.7]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.6...v1.1.7
[1.1.6]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.5...v1.1.6
[1.1.5]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.4...v1.1.5
[1.1.4]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.3...v1.1.4
[1.1.3]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.2...v1.1.3
[1.1.2]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.1...v1.1.2
[1.1.1]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/BrunoLagoa/memflow-command-system/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/BrunoLagoa/memflow-command-system/releases/tag/v1.0.0
