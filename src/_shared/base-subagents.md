---
description: It is not an executable command. Shared base for orchestration with or without subagents.
license: MIT
hidden: true
metadata:
  author: BrunoCastro
  version: "1.0.0"
---

# Subagent orchestration common base (normative reference)

Apply this block in commands that can delegate work to subagents (`/workflow`, `/brainstorm`, `/spec`, `/plan`, `/execute`, `/debug`, `/refactor`, `/review-code`, `/retro`).

Goal: allow **optional** parallelism and context isolation without losing Memflow predictability, gates and confirmations.

---

## Orchestration modes

- **Without subagents (default):** all work happens in the main context, sequentially. Cheaper and predictable.
- **With subagents:** well-scoped tasks are sent to subagents (own context window), in parallel when independent, and the main agent consolidates the reports.

---

## Who decides (CRITICAL)

- The mode is decided in `/workflow`, **for each new task**, in a structured dialog (see Step 5.1 of `/workflow`).
- The default is **Without subagents**.
- The decision holds for the following commands of the same task and must appear in the `/workflow` `### Strategy` as `Orquestração: Com subagents | Sem subagents`.
- Later commands read this decision; when absent → operate **Without subagents**.
- The user can switch the mode at any time by asking explicitly; in that case, record the switch in `## Analysis`.

---

## Target capability

The subagent tool depends on the active target (see the *Subagents* section in `_shared/target-adapter.md`):

| Target | Tool | Note |
| ------ | ---- | ---- |
| `claude` | Agent (subagents) | multiple calls in the same message run in parallel |
| `opencode` | Task (`general`, `explore`) | `explore` is read-only; `general` cannot spawn further subagents |
| `cursor` | Task (subagents) | multiple calls in the same message run in parallel; custom subagents in `.cursor/agents/` |
| `vscode` | `runSubagent` (alias `agent`) | available in Copilot Chat Agent mode |

If the tool is not available in the session (no-tools mode, denied permission, Ask mode, old version):

- DO NOT block
- operate **Without subagents** (sequential fallback)
- warn explicitly in the response: `Orquestração: Sem subagents (fallback — ferramenta indisponível)`

---

## Allowed uses (closed list)

1. **Fact-finding (read-only):** explore code, docs or external sources to answer a factual question. Used by `/brainstorm`, `/spec`, `/plan`, `/debug`, `/refactor`, `/retro`.
2. **Parallel review:** independent review axes that must not pollute each other's context. Used by `/review-code`.
3. **Frontier implementation:** `[P]` tasks of the plan frontier, isolated from each other. Used by `/execute`.
4. **Parallel design:** alternative, radically different shapes for the same interface. Used by `/refactor`.

Any other use → DO NOT delegate; run in the main context.

---

## Rules for the subagent (MANDATORY)

Every subagent brief must:

- have a **closed scope**: one question or one task, with a verifiable completion criterion
- communicate through **context pointers** (paths to spec, plan, brainstorm, ADRs, commits) instead of copying content
- state the response limit (e.g. up to 400 words) and the report format
- declare what the subagent is forbidden to do:
  - ask the user questions (decisions remain with the main agent and the user)
  - run the next command of the flow
  - write to `.agents/memory/` or `.agents/domain/`
  - update the saved plan (the main agent is the **single writer** of the plan)
  - push or change shared branches (commit is only allowed on the task's own branch, when isolated in a worktree by `/execute`)

---

## Rules for the main agent (MANDATORY)

- Send independent subagents **in the same message** so they run in parallel.
- Practical limit: up to 4 simultaneous subagents per round.
- While a fact-finding runs, continue only with what does not depend on it.
- **Do not trust blindly:** verify the reports (run the cited test/command, open the cited code) before using them as evidence.
- Consolidate results and decisions in its own context and in the command output.
- HARD-GATEs, save gates and explicit confirmations remain fully in force.
- Subagent model choice follows `model-policy.md`: economic for fact-finding; same level as the task for implementation and review.

---

## Output

Every command applying this block records in `## Analysis`:

- `Orquestração: Com subagents / Sem subagents / Sem subagents (fallback)`
- when there are subagents: a short list of what was delegated and the consolidated result

---

## Precedence rule

- This file defines the common orchestration pattern.
- Commands can restrict (never extend) the allowed uses.
- Non-overwriteable invariants:
  - default is Without subagents
  - the mode decision belongs to `/workflow` (or to an explicit user request)
  - missing tool → sequential fallback with warning, without blocking
  - subagents do not decide, do not ask the user and do not write memory, domain or plan
  - Memflow gates and confirmations are not bypassed by subagents
