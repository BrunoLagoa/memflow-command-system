---
name: retro
description: Session retrospective focused on the agent environment (not the code) — analyzes the session and suggests improvements to navigation, automated checks, coding standards, steering files (AGENTS.md/CLAUDE.md), tool economy and information access, ordered by severity. Mechanical mistakes become deterministic checks; judgement calls become standards for the reviewer. Does not apply changes; awaits confirmation. Output: Status, Analysis, Problems and Next steps.
license: MIT
metadata:
  author: BrunoCastro
  version: "1.0.0"
---

## Common normative reference

Mandatory application:

- `_shared/base-output.md`
- `_shared/base-preconditions.md`
- `_shared/base-degraded-mode.md`
- `_shared/base-subagents.md`
- `_shared/target-adapter.md`
- `model-policy.md`

---

## Objective

Improve the **environment** the agent works in, so the next sessions start better:

- find what cost time, tokens or rework in the session
- propose changes to the environment (not to product code)
- prioritize the most severe

---

## System integration

This command:

- is optional and runs at the end of a task (after `/review`, `/review-code` or `/memory-save`), especially when the session went sideways
- can also run after a `/debug`, asking what would have prevented the bug
- DOES NOT implement the improvements: the chosen ones go to `/workflow` → `/plan` or `/execute`
- DOES NOT replace `/memory-save`: **project** decisions go to memory; **environment** improvements stay here

---

## Model usage (ALIGNED TO MODEL-POLICY)

- intermediate model by default
- escalate only when the analyzed session is long or complex

---

## Primary sources

Analyze the session named by the user; if none, the current session:

- the current conversation history (preferred primary source — run `/retro` **before** clearing the context)
- `.agents/memory/session-memory.md` and `.agents/memory/quality-metrics.md` (when they exist)
- target session logs, when the user points to the path
- the repository's steering files and checks: `AGENTS.md`, `CLAUDE.md`, `CODING_STANDARDS.md`, `CONTRIBUTING.md`, `.agents/rules/**`, lint/test scripts, pre-commit configs and CI workflows

Before proposing a new check, read the existing check commands (`lint`/`check`/`test` scripts, CI): a check that already exists but is unwired or broken is the finding, not a reinvention.

---

## Candidate categories

- **Navigation:** did the agent take long to find files or information? Are there hidden dependencies between files? Would a navigation pointer help?
- **Automated checks:** could any agent mistake have been caught by lint, typing, tests or a file checker? A repository with no guardrail (no pre-commit and no CI running lint/typecheck/test) is a finding in itself.
- **Coding standards:** should the reviewer get a new rule, or have a rule removed/clarified?
- **Steering files:** do `AGENTS.md`/`CLAUDE.md` hold instructions that should become a coding standard or an automated check? Are they too large?
- **Tool economy:** were there expensive calls that could be streamlined? Is any tool (CLI, MCP) token-inefficient?
- **No-ops:** instructions that do not change agent behavior and only take up context.
- **Information access:** was crucial information missing (dev server logs, read-only access to external services)?

---

## Classification rules (MANDATORY)

- **Mechanical violation** (fixed syntactic pattern, banned API, import shape, file-location rule) → **deterministic check** (a rule in the repo's linter, a pre-commit hook or a CI job, whichever is cheapest). Prefer building the check over writing the rule.
- **Judgement call** (cross-file consistency, "matches the surrounding style") → **coding standard** in `CODING_STANDARDS.md` (or the repo's equivalent document), read by the reviewer.
- The reviewer (`/review-code`) enforces standards; the implementer (`/execute`) has the most context pressure and must not carry rules the reviewer can enforce.
- `AGENTS.md`/`CLAUDE.md` are pushed into every agent's context: use them sparingly, preferably only for navigation pointers.
- Before creating a new document, look for an existing one.

---

## Subagent orchestration

Apply `_shared/base-subagents.md`. Only when the `/workflow` decision is `Orquestração: Com subagents`:

- **Fact-finding:** read-only subagents may scan long session logs and the repo's steering/check files in parallel, reporting evidence
- classification, prioritization and the proposal stay in the main context

Without subagents → analyze everything in the main context.

---

## Rules

- DO NOT change code, configs, `AGENTS.md`/`CLAUDE.md` or CI in this command
- DO NOT propose a change without evidence from the session (cite the moment or call that motivated it)
- DO NOT duplicate what was already recorded by `/memory-save`
- Order candidates by severity: **Alta** (caused an error or relevant rework) → **Média** (cost time/tokens) → **Baixa** (comfort improvement)
- Redact secrets in any quoted excerpt

---

## Mandatory output format

## Status

- Retro completed / Waiting for data / Blocked

---

## Analysis

### Analyzed session

- source (current session, given log) and summary of what happened

### Candidates (by severity)

For each candidate:

- **Severity:** Alta / Média / Baixa
- **Category:** Navigation / Automated checks / Coding standards / Steering files / Tool economy / No-ops / Information access
- **Evidence:** what happened in the session
- **Proposal:** the environment change
- **Change type:** deterministic check / coding standard / navigation pointer / tool / instruction removal

### Orchestration

- Com subagents / Sem subagents / Sem subagents (fallback)

---

## Problems

- analysis limitations (compacted session, unavailable logs)

If there is none:
→ None

---

## Next steps

- Choose which candidates to implement (structured dialog)
- Go to `/workflow` with the chosen candidates
- Wait for explicit confirmation from the user before any new command
