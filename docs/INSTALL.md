# Installation guide

This guide covers the **advanced installation options** for `memflow-command-system`. For the recommended interactive flow, see the [README quick start](../README.md#quick-start).

<!-- I18N -->

**English** | [Português (Brasil)](./INSTALL.pt-BR.md)

<!-- /I18N -->

## Table of contents

- [Installation paths](#installation-paths)
- [Scope by target](#scope-by-target)
- [Non-interactive installation](#non-interactive-installation)
- [Update](#update)
- [Version check](#version-check)
- [Uninstall](#uninstall)
- [Bootstrap source vs installed payload](#bootstrap-source-vs-installed-payload)

## Installation paths

Where files actually land after install:

| Target            | Scope   | Path                                                       |
| ----------------- | ------- | ---------------------------------------------------------- |
| `opencode`        | global  | `~/.config/opencode/commands/memflow`                      |
| `opencode`        | local   | `<project>/.opencode/commands/memflow`                     |
| `vscode`          | project | `<project>/.github/prompts/memflow.<command>.prompt.md`    |
| `cursor`          | project | `<project>/.cursor/commands/memflow/<command>.md`          |
| `claude`          | project | `<project>/.claude/commands/memflow/<command>.md`          |

## Scope by target

- **`opencode`** — supports both `global` and `local` scopes.
  - References to `_shared/*.md` and `model-policy.md` are inlined into each generated command file.
  - The installed payload contains only executable command files inside `commands/memflow` (no standalone `_shared/` or `model-policy.md`).
- **`vscode`** — single project installation in `.github/prompts` (no global/local split).
  - References to `_shared/...` and `model-policy.md` are inlined into each generated prompt.
  - `target-adapter.md` references are resolved to `target-adapter.vscode.md`.
  - OpenCode-only path rules are not carried into VSCode prompts.
- **`cursor`** — single project installation in `.cursor/commands/memflow` (no global/local split).
  - References to `_shared/*.md` and `model-policy.md` are inlined into each generated command file.
  - Generated files strip top-level frontmatter and promote the `description` field as the first visible line to improve Cursor command list descriptions.
- **`claude`** — single project installation in `.claude/commands/memflow` (no global/local split).
  - References to `_shared/*.md` and `model-policy.md` are inlined into each generated command file.
  - `target-adapter.md` references are resolved to `target-adapter.claude.md`.
  - Generated files keep their YAML frontmatter, since Claude Code reads `description` natively; the `memflow` subdirectory appears as the `(project:memflow)` namespace in `/help`.

For runtime command resolution on `opencode`, normative files are looked up from the active command root first (auto-detecting `global` vs `local`), and only then fall back to official path discovery (`global → local`).

## Non-interactive installation

Use these in CI or scripted environments.

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

### OpenCode — Local (current project)

**macOS/Linux**

```bash
curl -fsSL https://raw.githubusercontent.com/BrunoLagoa/memflow-command-system/main/scripts/install.sh \
  | bash -s -- install --non-interactive --scope local --project-dir . --target opencode
```

**PowerShell**

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 install -NonInteractive -Scope local -ProjectDir . -Target opencode
```

### VSCode — Single project installation

**macOS/Linux**

```bash
curl -fsSL https://raw.githubusercontent.com/BrunoLagoa/memflow-command-system/main/scripts/install.sh \
  | bash -s -- install --non-interactive --target vscode --project-dir .
```

**PowerShell**

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 install -NonInteractive -Target vscode -ProjectDir .
```

### Cursor — Single project installation

**macOS/Linux**

```bash
curl -fsSL https://raw.githubusercontent.com/BrunoLagoa/memflow-command-system/main/scripts/install.sh \
  | bash -s -- install --non-interactive --target cursor --project-dir .
```

**PowerShell**

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 install -NonInteractive -Target cursor -ProjectDir .
```

### Claude Code — Single project installation

**macOS/Linux**

```bash
curl -fsSL https://raw.githubusercontent.com/BrunoLagoa/memflow-command-system/main/scripts/install.sh \
  | bash -s -- install --non-interactive --target claude --project-dir .
```

**PowerShell**

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 install -NonInteractive -Target claude -ProjectDir .
```

## Update

By default, `update` uses the latest tagged release.

If there is no previous installation in the requested target:
- **interactive mode** explains the issue and asks whether to start a fresh install;
- **non-interactive mode** fails with an explicit error and exit code `2`.

Without `--scope`, `update` uses manifest auto-discovery:
- on `opencode`, it updates detected scopes (`global` and/or `local`);
- on `vscode`, it updates generated files in `<project>/.github/prompts`;
- on `cursor`, it updates generated command files in `<project>/.cursor/commands/memflow`;
- on `claude`, it updates generated command files in `<project>/.claude/commands/memflow`.

Run from the **same directory** where you usually work. For `vscode`, `cursor`, and `claude`, pass `--target <target> --project-dir .` (or `-Target <target> -ProjectDir .` in PowerShell).

**macOS/Linux**

```bash
curl -fsSL https://raw.githubusercontent.com/BrunoLagoa/memflow-command-system/main/scripts/install.sh \
  | bash -s -- update --non-interactive
```

**PowerShell**

```powershell
powershell -ExecutionPolicy Bypass -Command "iwr https://raw.githubusercontent.com/BrunoLagoa/memflow-command-system/main/scripts/install.ps1 -OutFile $env:TEMP\install.ps1; & $env:TEMP\install.ps1 update -NonInteractive"
```

## Version check

`check` verifies whether a newer version is available without changing the installation.

Without `--scope`, `check` uses manifest auto-discovery:
- on `opencode`, it checks installed scopes;
- on `vscode`, it checks the single project installation from `<project>/.github/.memflow-install.json`;
- on `cursor`, it checks the single project installation from `<project>/.cursor/commands/.memflow-install.json`;
- on `claude`, it checks the single project installation from `<project>/.claude/commands/.memflow-install.json`.

**macOS/Linux**

```bash
curl -fsSL https://raw.githubusercontent.com/BrunoLagoa/memflow-command-system/main/scripts/install.sh \
  | bash -s -- check --non-interactive
```

**PowerShell**

```powershell
powershell -ExecutionPolicy Bypass -Command "iwr https://raw.githubusercontent.com/BrunoLagoa/memflow-command-system/main/scripts/install.ps1 -OutFile $env:TEMP\install.ps1; & $env:TEMP\install.ps1 check -NonInteractive"
```

## Uninstall

Use the same `--scope` and `--project-dir` values from [Scope by target](#scope-by-target).

If no installation exists in the informed target, `uninstall` returns an explicit error with exit code `2` to avoid false-success scenarios.

Without `--scope`, `uninstall` also uses manifest auto-discovery:
- on `opencode`, it removes detected scopes;
- on `vscode`, it removes generated `memflow.*` files from `.github/prompts`;
- on `cursor`, it removes generated command files from `.cursor/commands/memflow`;
- on `claude`, it removes generated command files from `.claude/commands/memflow`.

**macOS/Linux**

```bash
curl -fsSL https://raw.githubusercontent.com/BrunoLagoa/memflow-command-system/main/scripts/install.sh \
  | bash -s -- uninstall --non-interactive
```

**PowerShell**

```powershell
powershell -ExecutionPolicy Bypass -Command "iwr https://raw.githubusercontent.com/BrunoLagoa/memflow-command-system/main/scripts/install.ps1 -OutFile $env:TEMP\install.ps1; & $env:TEMP\install.ps1 uninstall -NonInteractive"
```

## Bootstrap source vs installed payload

- The bootstrap command (`curl .../main/scripts/install.sh` or remote `install.ps1`) downloads the installer modules from branch `main` by default.
- The installed command payload (`src/*`) is resolved from the latest release tag by default.
- For reproducible bootstrap behavior, pin `MEMFLOW_REF` before running the installer script.

**Example (macOS/Linux)**

```bash
export MEMFLOW_REF=v1.1.24
curl -fsSL https://raw.githubusercontent.com/BrunoLagoa/memflow-command-system/${MEMFLOW_REF}/scripts/install.sh \
  | bash -s -- install --non-interactive
```
