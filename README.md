<p align="center">
  <img src="docs/assets/logo.webp" alt="Memflow logo" width="300" />
</p>

<h1 align="center">Memflow Command System</h1>


<p align="center">
  Advanced AI engineering system for a full SDLC (Software Development Life Cycle), with intelligent orchestration, disciplined execution, strict validation, and evolving memory for decisions.
</p>

<p align="center">
  Build high-quality software faster. An open-source toolkit focused on product scenarios and predictable outcomes, instead of rebuilding everything from scratch based on intuition.
</p>

<p align="center">
  <a href="https://github.com/BrunoLagoa/memflow-command-system/stargazers"><img src="https://img.shields.io/github/stars/BrunoLagoa/memflow-command-system?style=social" alt="GitHub stars" /></a>
  <a href="https://github.com/BrunoLagoa/memflow-command-system/releases/latest"><img src="https://img.shields.io/github/v/release/BrunoLagoa/memflow-command-system" alt="Latest Release" /></a>
  <a href="https://github.com/BrunoLagoa/memflow-command-system/blob/main/LICENSE"><img src="https://img.shields.io/github/license/BrunoLagoa/memflow-command-system" alt="License" /></a>
  <a href="https://github.com/BrunoLagoa/memflow-command-system"><img src="https://hits.sh/github.com/BrunoLagoa/memflow-command-system.svg?label=Project%20views&color=f1c40f" alt="Project views" /></a>
</p>

<!-- README-I18N:START -->

**English** | [Português (Brasil)](./README.pt-BR.md)

<!-- README-I18N:END -->

## System overview

`memflow-command-system` is an operational command suite that turns ad-hoc AI usage into a predictable, auditable engineering workflow.

Instead of simply "asking for code," you run a system with clear stages:

- **orchestration** to choose strategy and model
- **execution** to implement safely
- **validation** to block violations before completion
- **memory** to preserve decisions and reduce rework

In practice, it acts as an SDLC control layer for teams that want speed with quality.

## Key differentiators

- Stateful workflow with decision reuse by score (`0-100`)
- Strict final gate with binary output (`OK` or `BLOCKED`)
- Cost/quality model policy with primary model plus same-level fallbacks
- Functional degraded mode when `.agents` does not exist
- Smart memory persistence with decision versioning (`(update)`)
- Modular command structure with shared rules in `_shared`
- MCP integration for code, contextual memory, and external docs

## How it works (simplified flow)

```text
/context
   ↓
/workflow
   ↓
/execute (or /plan, when needed)
   ↓
(/memory-save, if recommended)
   ↓
/review
   ↓
/review-enforce-rules (Optional)
```

## Architecture (orchestration vs capabilities)

### 1) Orchestration (decision and control)

- `/context`: loads context, memory, and operating mode
- `/workflow`: classifies task, decides strategy, level, primary model, and fallback options
- `/execute`: applies the decision with controlled fallback
- `/review`: validates technical and architectural adherence
- `/review-enforce-rules`: strict final validation (recommended/optional)
- `model-policy.md`: model selection and escalation strategy

### 2) Capabilities (specialized resolution)

- Discovery and definition: `/prd`, `/spec`, `/plan`, `/brainstorm`
- Implementation and quality: `/execute`, `/debug`, `/refactor`, `/test-plan`
- Memory: `/memory-init`, `/memory-save`

### 3) Shared rules

Files in `src/_shared` centralize cross-cutting standards:

- `base-output.md`
- `base-preconditions.md`
- `base-degraded-mode.md`

## Getting started (quick start)

### Prerequisites

- Environment with slash-command support
- `bash` and `curl` for macOS/Linux
- `PowerShell 7+` for native Windows

### Installation

#### Option A - one-liner (macOS/Linux)

```bash
curl -fsSL https://raw.githubusercontent.com/BrunoLagoa/memflow-command-system/main/scripts/install.sh | bash -s -- install
```

The `MEMFLOW` wizard guides choices for:

1. Operating system
2. Installation platform (`OpenCode`)
3. Scope (`local` or `global`)

#### Option B - local script execution (macOS/Linux)

```bash
git clone https://github.com/BrunoLagoa/memflow-command-system.git
cd memflow-command-system
chmod +x scripts/install.sh
./scripts/install.sh install
```

#### Option C - native Windows (PowerShell)

```powershell
git clone https://github.com/BrunoLagoa/memflow-command-system.git
cd memflow-command-system
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 install
```

#### Global vs local scope

- **`global`**: installed in user profile (`~/.config/...`); available from any directory. In non-interactive commands, use `--scope global` (or `-Scope global` in PowerShell).
- **`local`**: installed inside a project; use `--scope local --project-dir <path>` (usually `--project-dir .` at repository root).

The same convention applies to **`install`**, **`memflowctl`** (`update`, `check`, `uninstall`), and **`install.sh` / `install.ps1`** when you pass scope explicitly.

For **`update`**, if MEMFLOW was installed previously, the installer can **infer** global vs local from the manifest (`.memflow-install.json`); in that case `--scope` / `-Scope` is optional - see [Update to a new version](#update-to-a-new-version).

### Non-interactive installation

Examples below follow the convention from [Global vs local scope](#global-vs-local-scope).

#### Global

##### macOS/Linux

```bash
curl -fsSL https://raw.githubusercontent.com/BrunoLagoa/memflow-command-system/main/scripts/install.sh | bash -s -- install --non-interactive --scope global --target opencode
```

##### PowerShell

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 install -NonInteractive -Scope global -Target opencode
```

#### Local (current project)

##### macOS/Linux

```bash
curl -fsSL https://raw.githubusercontent.com/BrunoLagoa/memflow-command-system/main/scripts/install.sh | bash -s -- install --non-interactive --scope local --project-dir . --target opencode
```

##### PowerShell

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install.ps1 install -NonInteractive -Scope local -ProjectDir . -Target opencode
```

### Update to a new version

By default, update uses the latest tagged release.

If there is no previous installation in the requested scope:
- in **interactive** mode, the command explains the issue and asks whether to start a fresh install;
- in **non-interactive** mode, it fails with an explicit error and exit code `2`.

If you **already installed** MEMFLOW, the installer can **auto-detect** whether installation was **global** or **local** by reading the manifest (`.memflow-install.json`). In this case, passing `--scope` / `-Scope` is not mandatory - use it only when you want to force a scope explicitly.

Without `--scope`, `update` only affects scopes where installation is detected by manifest: if only one scope exists, it updates only that one; if both **global and local** exist, it applies to both in order `global` -> `local`.

#### General command

Use `install.sh` / `install.ps1` directly from the repository (does not require `memflowctl` in PATH).

Run from the **same directory** where you usually work (for local installation, typically the project root where `.opencode/commands` exists).

##### macOS/Linux

```bash
curl -fsSL https://raw.githubusercontent.com/BrunoLagoa/memflow-command-system/main/scripts/install.sh | bash -s -- update --non-interactive
```

##### PowerShell

```powershell
powershell -ExecutionPolicy Bypass -Command "iwr https://raw.githubusercontent.com/BrunoLagoa/memflow-command-system/main/scripts/install.ps1 -OutFile $env:TEMP\install.ps1; & $env:TEMP\install.ps1 update -NonInteractive"
```

### Version check

`check` verifies whether a newer version is available without changing the installation.

Without `--scope`, `check` evaluates only scopes with installation detected by manifest: if there is only one scope, it checks only that one; if both **global and local** exist, it checks both in order `global` -> `local`.

#### General command

##### macOS/Linux

```bash
curl -fsSL https://raw.githubusercontent.com/BrunoLagoa/memflow-command-system/main/scripts/install.sh | bash -s -- check --non-interactive
```

##### PowerShell

```powershell
powershell -ExecutionPolicy Bypass -Command "iwr https://raw.githubusercontent.com/BrunoLagoa/memflow-command-system/main/scripts/install.ps1 -OutFile $env:TEMP\install.ps1; & $env:TEMP\install.ps1 check -NonInteractive"
```

### Remove installation

Use the same **`--scope`** and **`--project-dir`** values from [Global vs local scope](#global-vs-local-scope).

If no installation exists in the informed scope, `uninstall` returns an explicit error with exit code `2` to avoid false-success scenarios.

Without `--scope`, `uninstall` also uses manifest auto-discovery and removes only scopes that actually have an installation: if one scope exists, removes only that one; if both **global and local** are found, removes both in order `global` -> `local`.

#### General command

##### macOS/Linux

```bash
curl -fsSL https://raw.githubusercontent.com/BrunoLagoa/memflow-command-system/main/scripts/install.sh | bash -s -- uninstall --non-interactive
```

##### PowerShell

```powershell
powershell -ExecutionPolicy Bypass -Command "iwr https://raw.githubusercontent.com/BrunoLagoa/memflow-command-system/main/scripts/install.ps1 -OutFile $env:TEMP\install.ps1; & $env:TEMP\install.ps1 uninstall -NonInteractive"
```

### Installation targets

These match the **global** and **local** modes described in [Global vs local scope](#global-vs-local-scope):

- `global`: `~/.config/opencode/commands/memflow`
- `local`: `<project>/.opencode/commands/memflow`

### First use

```bash
/context
/workflow
```

If the task is simple, the next step is usually:

```bash
/execute
/review
/review-enforce-rules  # recommended for strict final validation
```

## Real flow example

Example: implementing a medium-complexity feature with active memory.

```text
1. /context
   - Loads .agents and existing memory

2. /workflow
   - Detects previous decision in decisions.md
   - Reuses decision when score is high

3. /plan
   - Required due to complexity/risk

4. /execute
   - Implements with validations and tests
   - Calculates session relevance score

5. /memory-save
   - Records relevant decision with category, impact, and score

6. /review
   - Checks quality, security, and architecture

7. /review-enforce-rules (optional/recommended)
   - Applies additional strict validation (OK or BLOCKED)
```

## Tool support

This section is continuously updated as new environments are validated.

| Tool | Support | Notes |
| ---------- | ------- | ----------- |
| `opencode` | ✅ | Main project platform, with full support for slash commands and SDLC flow. |
| `VSCode` | ⏳ | Support pending validation; we still need to test this environment. |
| `Antigravity` | ⏳ | Support pending validation; we still need to test this environment. |
| `Cursor` | ⏳ | Support pending validation; we still need to test this environment. |

## Documentation (doc links)

- Version history: [`CHANGELOG.md`](CHANGELOG.md)
- SDLC conceptual guide (English): [`docs/SDLC.md`](docs/SDLC.md)
- SDLC conceptual guide (Portuguese): [`docs/SDLC.pt-BR.md`](docs/SDLC.pt-BR.md)
- Model policy (operational): [`src/model-policy.md`](src/model-policy.md)
- Context command: [`src/context.md`](src/context.md)
- Decision command: [`src/workflow.md`](src/workflow.md)
- Execution command: [`src/execute.md`](src/execute.md)
- Optional strict validation: [`src/review-enforce-rules.md`](src/review-enforce-rules.md)

## System philosophy

> Workflow decides.  
> Model executes.  
> Rules protect.

Operational principles:

- Start cheap, escalate model only when needed
- Do not execute without context and workflow decision
- Do not lose learning: important decisions become structured memory
- Do not "approve by feeling": validation must be explicit and traceable

## Use cases

- Teams that want to standardize AI-assisted SDLC with governance
- Projects that suffer from inconsistent decisions across sessions
- Environments that need to balance model cost and technical quality
- Flows with high architectural/security compliance requirements
- Engineering AI adoption without sacrificing predictability

## Roadmap

- Expand `docs/` with complementary guides beyond SDLC and brand assets
- Add automated validation suite for commands
- Provide stack-based templates for faster onboarding
- Add effectiveness metrics (lead time, rework, cost per task)

## People behind Memflow

This project evolves with contributions from people who believe in disciplined, practical, and auditable AI software engineering.

<p align="left">
  <a href="https://github.com/BrunoLagoa/memflow-command-system/graphs/contributors">
    <img src="https://contrib.rocks/image?repo=BrunoLagoa/memflow-command-system&max=100" alt="Project contributors" width="45" />
  </a>
</p>

Want to show up here too? Open an issue, suggest improvements, or send a PR.

## Support

For support, open a GitHub issue. Bug reports, feature requests, and usage questions are welcome.

## License

This project is licensed under the MIT License. See [`LICENSE`](LICENSE) for full terms.

---

If you want AI acting as a real engineering copilot, not just a snippet generator, this system was built for that.
