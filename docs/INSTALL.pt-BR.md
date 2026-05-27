# Guia de instalação

Este guia cobre as **opções avançadas de instalação** do `memflow-command-system`. Para o fluxo interativo recomendado, veja o [quick start do README](../README.pt-BR.md#quick-start).

<!-- I18N -->

[English](./INSTALL.md) | **Português (Brasil)**

<!-- /I18N -->

## Sumário

- [Destinos de instalação](#destinos-de-instalação)
- [Escopo por target](#escopo-por-target)
- [Instalação não-interativa](#instalação-não-interativa)
- [Atualizar](#atualizar)
- [Check de versão](#check-de-versão)
- [Desinstalar](#desinstalar)
- [Bootstrap remoto vs payload instalado](#bootstrap-remoto-vs-payload-instalado)

## Destinos de instalação

Onde os arquivos ficam após instalação:

| Target            | Escopo  | Caminho                                                    |
| ----------------- | ------- | ---------------------------------------------------------- |
| `opencode`        | global  | `~/.config/opencode/commands/memflow`                      |
| `opencode`        | local   | `<projeto>/.opencode/commands/memflow`                     |
| `vscode`          | projeto | `<projeto>/.github/prompts/memflow.<comando>.prompt.md`    |
| `cursor`          | projeto | `<projeto>/.cursor/commands/memflow/<comando>.md`          |

## Escopo por target

- **`opencode`** — suporta escopos `global` e `local`.
  - Referências a `_shared/*.md` e `model-policy.md` são injetadas no próprio arquivo de comando gerado.
  - O payload instalado contém apenas arquivos executáveis em `commands/memflow` (sem `_shared/` ou `model-policy.md` standalone).
- **`vscode`** — instalação **única por projeto** em `.github/prompts` (sem separação global/local).
  - Referências a `_shared/...` e `model-policy.md` são injetadas no próprio prompt gerado.
  - Referências a `target-adapter.md` são resolvidas para `target-adapter.vscode.md`.
  - Regras de caminho exclusivas do OpenCode não são carregadas para prompts VSCode.
- **`cursor`** — instalação **única por projeto** em `.cursor/commands/memflow` (sem separação global/local).
  - Referências a `_shared/*.md` e `model-policy.md` são injetadas no próprio arquivo de comando gerado.
  - Os comandos gerados removem frontmatter no topo e promovem o campo `description` para a primeira linha visível, melhorando a descrição exibida na lista de comandos do Cursor.

Na execução dos comandos em `opencode`, os arquivos normativos são resolvidos primeiro pela raiz do comando ativo (com detecção automática de escopo `global` vs `local`) e só depois por descoberta dos caminhos oficiais (`global → local`).

## Instalação não-interativa

Use estas variantes em CI ou ambientes scriptados.

### OpenCode — Global

**macOS/Linux**

```bash
curl -fsSL https://raw.githubusercontent.com/BrunoLagoa/memflow-command-system/main/scripts/install.sh \
  | bash -s -- install --non-interactive --scope global --target opencode
```

**PowerShell**

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 install -NonInteractive -Scope global -Target opencode
```

### OpenCode — Local (projeto atual)

**macOS/Linux**

```bash
curl -fsSL https://raw.githubusercontent.com/BrunoLagoa/memflow-command-system/main/scripts/install.sh \
  | bash -s -- install --non-interactive --scope local --project-dir . --target opencode
```

**PowerShell**

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 install -NonInteractive -Scope local -ProjectDir . -Target opencode
```

### VSCode — Instalação única por projeto

**macOS/Linux**

```bash
curl -fsSL https://raw.githubusercontent.com/BrunoLagoa/memflow-command-system/main/scripts/install.sh \
  | bash -s -- install --non-interactive --target vscode --project-dir .
```

**PowerShell**

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 install -NonInteractive -Target vscode -ProjectDir .
```

### Cursor — Instalação única por projeto

**macOS/Linux**

```bash
curl -fsSL https://raw.githubusercontent.com/BrunoLagoa/memflow-command-system/main/scripts/install.sh \
  | bash -s -- install --non-interactive --target cursor --project-dir .
```

**PowerShell**

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 install -NonInteractive -Target cursor -ProjectDir .
```

## Atualizar

Por padrão, o `update` usa a release tagueada mais recente.

Se não existir instalação prévia no alvo solicitado:
- no modo **interativo**, o comando informa o problema e pergunta se deve iniciar uma instalação nova;
- no modo **não-interativo**, falha com erro explícito e código de saída `2`.

Sem `--scope`, o `update` usa autodiscovery por manifest:
- em `opencode`, atualiza os escopos detectados (`global` e/ou `local`);
- em `vscode`, atualiza os arquivos gerados em `<projeto>/.github/prompts`;
- em `cursor`, atualiza os comandos gerados em `<projeto>/.cursor/commands/memflow`.

Execute no **mesmo diretório** em que você costuma trabalhar. Para `vscode` e `cursor`, informe `--target <target> --project-dir .` (ou `-Target <target> -ProjectDir .` no PowerShell).

**macOS/Linux**

```bash
curl -fsSL https://raw.githubusercontent.com/BrunoLagoa/memflow-command-system/main/scripts/install.sh \
  | bash -s -- update --non-interactive
```

**PowerShell**

```powershell
powershell -ExecutionPolicy Bypass -Command "iwr https://raw.githubusercontent.com/BrunoLagoa/memflow-command-system/main/scripts/install.ps1 -OutFile $env:TEMP\install.ps1; & $env:TEMP\install.ps1 update -NonInteractive"
```

## Check de versão

O `check` verifica se existe versão mais recente sem alterar a instalação.

Sem `--scope`, o `check` usa autodiscovery por manifest:
- em `opencode`, verifica os escopos instalados;
- em `vscode`, verifica a instalação única do projeto via manifest em `<projeto>/.github/.memflow-install.json`;
- em `cursor`, verifica a instalação única do projeto via manifest em `<projeto>/.cursor/commands/.memflow-install.json`.

**macOS/Linux**

```bash
curl -fsSL https://raw.githubusercontent.com/BrunoLagoa/memflow-command-system/main/scripts/install.sh \
  | bash -s -- check --non-interactive
```

**PowerShell**

```powershell
powershell -ExecutionPolicy Bypass -Command "iwr https://raw.githubusercontent.com/BrunoLagoa/memflow-command-system/main/scripts/install.ps1 -OutFile $env:TEMP\install.ps1; & $env:TEMP\install.ps1 check -NonInteractive"
```

## Desinstalar

Use os mesmos valores de `--scope` e `--project-dir` da seção [Escopo por target](#escopo-por-target).

Se não existir instalação no alvo informado, o `uninstall` retorna erro explícito com código de saída `2` para evitar falso positivo de sucesso.

Sem `--scope`, o `uninstall` também usa descoberta automática por manifest:
- em `opencode`, remove os escopos detectados;
- em `vscode`, remove arquivos `memflow.*` gerados em `.github/prompts`;
- em `cursor`, remove comandos gerados em `.cursor/commands/memflow`.

**macOS/Linux**

```bash
curl -fsSL https://raw.githubusercontent.com/BrunoLagoa/memflow-command-system/main/scripts/install.sh \
  | bash -s -- uninstall --non-interactive
```

**PowerShell**

```powershell
powershell -ExecutionPolicy Bypass -Command "iwr https://raw.githubusercontent.com/BrunoLagoa/memflow-command-system/main/scripts/install.ps1 -OutFile $env:TEMP\install.ps1; & $env:TEMP\install.ps1 uninstall -NonInteractive"
```

## Bootstrap remoto vs payload instalado

- O bootstrap remoto (`curl .../main/scripts/install.sh` ou `install.ps1` remoto) baixa módulos do instalador da branch `main` por padrão.
- O payload instalado dos comandos (`src/*`) usa por padrão a release tag mais recente.
- Para bootstrap reproduzível, fixe `MEMFLOW_REF` antes de executar o instalador.

**Exemplo (macOS/Linux)**

```bash
export MEMFLOW_REF=v1.1.24
curl -fsSL https://raw.githubusercontent.com/BrunoLagoa/memflow-command-system/${MEMFLOW_REF}/scripts/install.sh \
  | bash -s -- install --non-interactive
```
