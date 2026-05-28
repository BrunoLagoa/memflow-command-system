<p align="center">
  <img src="docs/assets/logo.webp" alt="Memflow logo" width="240" />
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

---

## Quick start

One interactive command. It detects your environment, asks 3 questions, and installs.

**macOS / Linux**

```bash
curl -fsSL https://raw.githubusercontent.com/BrunoLagoa/memflow-command-system/main/scripts/install.sh | bash -s -- install
```

**Windows (PowerShell)**

```powershell
powershell -ExecutionPolicy Bypass -Command "iwr https://raw.githubusercontent.com/BrunoLagoa/memflow-command-system/main/scripts/install.ps1 -OutFile $env:TEMP\install.ps1; & $env:TEMP\install.ps1 install"
```

The wizard guides you through:

1. **Operating system**
2. **Platform** — `OpenCode`, `VSCode`, or `Cursor`
3. **Scope** — `global` or `local` (when applicable)

Then jump straight to your first commands:

```text
/context
/workflow
```

> **New to Memflow?** Read the [first 10 minutes guide](docs/QUICKSTART.md) for a step-by-step walkthrough with real examples.

> **Need scripted installs, update, check or uninstall?** See the [advanced installation guide](docs/INSTALL.md).

---

## Why Memflow?

Most AI workflows look like this: open chat, paste context, ask for code, hope for the best, repeat. Every session restarts from zero. Decisions evaporate. The same mistakes get re-litigated next week.

Memflow makes that flow look more like a real engineering team:

- A **workflow stage** that classifies the task, routes exploration when needed (`/brainstorm`), and picks the right strategy and model — cheap by default, escalating only when needed.
- An **execution stage** that implements with controlled fallbacks and explicit checkpoints.
- A **validation stage** with a strict final gate (`OK` or `BLOCKED`) — no "approval by feeling".
- A **memory layer** that captures relevant decisions with category, impact, and a `0–100` score, and reuses them across sessions.

The result is something you can audit, repeat, and trust.

---

## The flow

```text
┌─────────────┐    ┌──────────────┐    ┌─────────────┐    ┌────────────┐
│  /context   │ →  │  /workflow   │ →  │  /execute   │ →  │  /review   │
│             │    │              │    │  (or /plan) │    │            │
│ load memory │    │ decide model │    │  implement  │    │  validate  │
└─────────────┘    └──────┬───────┘    └─────────────┘    └────────────┘
                          │
                    ┌─────▼──────┐
                    │ /brainstorm│  optional — when clarity is low or trade-offs exist
                    └────────────┘
                                              ↓
                                       ┌──────────────┐
                                       │ /memory-save │
                                       │  (optional)  │
                                       └──────────────┘
```

When `/workflow` detects insufficient clarity or unresolved trade-offs, it routes to `/brainstorm` first. Handoff after approval: `/prd`, `/spec`, or `/plan`.

For high-risk work, finish with `/review-code` (deep technical review) and `/review-enforce-rules` (strict final gate).

---

## What's included

### Orchestration commands

The control layer that decides, executes, and validates.

| Command                  | What it does                                                                                  |
| ------------------------ | --------------------------------------------------------------------------------------------- |
| `/context`               | Load project context, memory, operating mode, and available skills                            |
| `/workflow`              | Classify the task; decide exploration (`/brainstorm`), execution strategy, level, primary model, and fallbacks |
| `/execute`               | Apply the decision with controlled fallback                                                   |
| `/review`                | Validate technical and architectural adherence                                                |
| `/review-code`           | Deep technical validation before production readiness                                         |
| `/review-enforce-rules`  | Strict final gate with binary output: `OK` or `BLOCKED`                                       |

### Capability commands

Specialized resolution for everyday tasks.

| Category                    | Commands                                          |
| --------------------------- | ------------------------------------------------- |
| Discovery & definition      | `/brainstorm`, `/prd`, `/spec`, `/plan`           |
| Implementation & quality    | `/execute`, `/debug`, `/refactor`, `/test-plan`   |
| Memory                      | `/memory-init`, `/memory-save`                    |

### Key differentiators

- **Structured exploration** — `/brainstorm` compares 2–5 approaches in a phased dialogue, with HARD-GATE, self-review, optional artifact save, and handoff to `/prd`, `/spec`, or `/plan`.
- **Decision reuse by score** — high-scoring decisions are auto-reused across sessions.
- **Cost/quality model policy** — primary model + same-level fallbacks; escalate only when justified.
- **Functional degraded mode** — keeps working even when `.agents` is missing.
- **Smart memory persistence** — decision versioning with `(update)` semantics.
- **Anti-compaction invariants** — pt-BR + Memflow identity re-hydrated via `/context` and `/workflow`.
- **MCP integration** — code, contextual memory, and external docs.
- **Live plans** — when `/plan` is saved, tasks are sized by complexity with status markers (`[ ]`, `[-]`, `[x]`, `[!]`) and execution modes (`[P]` parallel, `[S]` sequential).

---

## A real example

Implementing a medium-complexity feature with active memory:

```text
1. /context              → Loads .agents and existing memory
2. /workflow             → Detects previous decision, reuses if score is high
3. /plan                 → Required due to complexity/risk
4. /execute              → Implements with validations and tests; scores session relevance
5. /memory-save          → Records the decision with category, impact, and score
6. /review               → Checks quality, security, and architecture
7. /review-code          → Deep technical validation
8. /review-enforce-rules → Strict final gate (OK or BLOCKED) — optional, recommended
```

When scope or approach is unclear, insert `/brainstorm` after `/workflow` (step 3 becomes exploration and approval, then `/prd`, `/spec`, or `/plan`).

---

## Supported tools

| Tool        | Status | Notes                                                                              |
| ----------- | :----: | ---------------------------------------------------------------------------------- |
| OpenCode    |   ✅   | Main platform. Full slash command and SDLC support.                                |
| VSCode      |   ✅   | Installed via `--target vscode` as prompt files in `.github/prompts`.              |
| Cursor      |   ✅   | Installed via `--target cursor` as commands in `.cursor/commands/memflow`.         |
| Antigravity |   ⏳   | Pending validation.                                                                |

---

## Philosophy

> **Workflow decides. Model executes. Rules protect.**

Operating principles:

- **Start cheap, escalate when needed.** Don't burn the strongest model on a one-line fix.
- **No execution without a decision.** Context and workflow come first, always.
- **No silent progress.** Each step waits for explicit user confirmation.
- **Don't lose learning.** Important decisions become structured memory.
- **No "approval by feeling".** Validation is explicit and traceable.

---

## Documentation

| Doc                                                       | What's inside                                |
| --------------------------------------------------------- | -------------------------------------------- |
| [First 10 minutes](docs/QUICKSTART.md)                    | Step-by-step walkthrough with real examples  |
| [Advanced installation](docs/INSTALL.md)                  | Non-interactive install, update, check, uninstall, scope details, bootstrap pinning |
| [SDLC guide (English)](docs/SDLC.md)                      | Conceptual guide to the Memflow SDLC         |
| [SDLC guide (Português)](docs/SDLC.pt-BR.md)              | pt-BR version                                |
| [End-to-end examples](docs/examples/)                     | Real usage scenarios with full command flows |
| [Changelog](CHANGELOG.md)                                 | Version history                              |
| [Model policy](src/model-policy.md)                       | Model selection and escalation strategy      |
| Command specs                                             | [`/context`](src/context.md) · [`/workflow`](src/workflow.md) · [`/brainstorm`](src/brainstorm.md) · [`/execute`](src/execute.md) · [`/review-code`](src/review-code.md) · [`/review-enforce-rules`](src/review-enforce-rules.md) |

---

## Who is this for?

- Teams standardizing AI-assisted SDLC with governance
- Projects suffering from inconsistent decisions across sessions
- Environments balancing model cost and technical quality
- Flows with high architectural and security compliance requirements
- Engineering orgs adopting AI without sacrificing predictability

---

## Roadmap

- Provide stack-based templates for faster onboarding
- Add effectiveness metrics (lead time, rework, cost per task)
- Expand command specs with adaptive memory hints

---

## Contributing

This project follows [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/). Commit messages are validated in CI for pull requests and pushes to `main`.

Allowed types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`, `build`, `ci`.

## People

This project evolves with contributions from people who believe in disciplined, practical, and auditable AI software engineering.

<p align="left">
  <a href="https://github.com/BrunoLagoa/memflow-command-system/graphs/contributors">
    <img src="https://contrib.rocks/image?repo=BrunoLagoa/memflow-command-system&max=100" alt="Project contributors" width="45" />
  </a>
</p>

Want to show up here too? Open an issue, suggest improvements, or send a PR.

## Support

Open a GitHub issue. Bug reports, feature requests, and usage questions are welcome.

## License

MIT. See [`LICENSE`](LICENSE) for full terms.

---

<p align="center">
  If you want AI acting as a real engineering copilot — not just a snippet generator — this system was built for that.
</p>
