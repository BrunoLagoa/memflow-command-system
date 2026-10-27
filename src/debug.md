---
name: debug
description: Structured bug diagnosis with feedback loop first — builds a command that reproduces the bug (red), minimises the scenario, generates 3 to 5 ranked falsifiable hypotheses and instruments with tagged logs. Classifies the error (Simple/Structural/Critical) and indicates the most likely cause with evidence. Does not fix. Integrated into the workflow and `model-policy.md` of the active target (via `_shared/target-adapter.md`). Output: Status, Analysis, Problems and Next steps. Next step: /execute, /refactor or /plan depending on classification.
license: MIT
metadata:
  author: BrunoCastro
  version: "1.1.0"
---

## Common normative reference

Mandatory application:

- `_shared/base-output.md`
- `_shared/base-preconditions.md`
- `_shared/base-degraded-mode.md`
- `_shared/base-domain-model.md`
- `_shared/target-adapter.md`
- `model-policy.md`

---

## Objective

Deeply analyze an error, bug or unexpected behavior:

- build a feedback loop that reproduces the bug
- identify root cause
- prioritize falsifiable hypotheses
- guide investigation
- prepare base for safe correction

---

## System integration

This command:

- DOES NOT execute fixes
- DOES NOT replace `/execute`
- DOES NOT decide flow

It prepares for:

→ `/execute` (fix, with regression test before the fix — see *Bug fix* in `/execute`)
→ `/refactor` (structural improvement)
→ `/plan` (when necessary)

---

## Model usage (ALIGNED TO MODEL-POLICY)

This command should:

- use intermediate or advanced model
- prioritize diagnostic quality

---

## Rules

1. Base analysis on:
   - `.agents`
   - `docs`
   - expected system behavior
   - vocabulary from `.agents/domain/GLOSSARY.md` and ADRs of the area (when they exist)

2. DO NOT implement fixes
   - **reproduction** scripts, tests or harnesses and temporary instrumentation logs are NOT fixes and are allowed
   - every production code change that fixes the bug belongs to `/execute`

3. DO NOT theorize before a feedback loop exists (Phase 1)

4. After hypotheses:
   - rank them and indicate **a single most likely cause** (the first of the ranking)

---

## Redact secrets (MANDATORY)

- When showing commands, outputs and captured artifacts, replace every secret with `<REDACTED>`.
- Build loops using environment variables, so credentials stay in the environment and not in the output.
- Quote only the lines of artifacts (logs, HAR, headers) that carry the signal.

---

## Phase 1 — Feedback loop (MANDATORY)

**This is the main phase.** With a pass/fail signal that goes red on **this** bug, the cause will be found; without it, reading code will not solve it.

Ways to build one, in rough order of preference:

1. failing test at the seam that reaches the bug (unit, integration, e2e)
2. curl/HTTP script against a dev server
3. CLI invocation with a fixture, diffing output against a known-good snapshot
4. headless browser script (Playwright/Puppeteer) asserting on DOM/console/network
5. replay of a captured trace (request, payload, event log)
6. throwaway harness with a minimal subset of the system
7. property/fuzz loop for "sometimes wrong output"
8. bisection harness (`git bisect run`) when the bug appeared between two known states
9. differential loop: same input on old vs new version
10. structured HITL script (last resort, when only a human can trigger it)

Tighten the loop: faster, sharper signal (assert the exact symptom), more deterministic (pin time, seed, network). For non-deterministic bugs, the goal is to **raise the reproduction rate** until it is debuggable.

### Phase 1 completion criterion

Name **one command** already run at least once (show invocation and output, redacted) that is:

- [ ] **red-capable:** drives the real bug code path and asserts the **exact symptom** reported
- [ ] **deterministic:** same verdict on every run (or pinned, high reproduction rate)
- [ ] **fast:** seconds, not minutes
- [ ] **agent-runnable:** no human in the loop (except structured HITL)

### When a loop cannot be built

- STOP and say so explicitly
- list what was tried
- ask the user for: access to the environment that reproduces it, a captured artifact (redacted) or permission for temporary instrumentation
- status: `Aguardando dados`
- DO NOT move to hypotheses without a loop

---

## Phase 2 — Reproduce and minimise

- Confirm the loop produces the failure mode **described by the user** (wrong bug = wrong fix)
- Confirm reproducibility across multiple runs
- Capture the exact symptom (message, wrong output, timing)
- Minimise: cut inputs, callers, config, data and steps **one at a time**, re-running the loop after each cut
- Done when **every remaining element is load-bearing** (removing any one makes the loop go green)

---

## Phase 3 — Hypotheses

- Generate **3 to 5 ranked hypotheses** before testing any of them
- Each hypothesis must be **falsifiable**:
  - format: "If <X> is the cause, then <changing Y> will make the bug disappear / <changing Z> will make it worse"
  - a hypothesis without a prediction is a guess: discard or sharpen it
- **Show the ranking to the user before testing** (they may re-rank with domain knowledge); do not block if the user is away

---

## Phase 4 — Instrument

- Each probe maps to a prediction from Phase 3; **change one variable at a time**
- Preference: debugger/REPL → targeted logs at the boundaries that distinguish hypotheses → never "log everything and grep"
- **Tag every debug log** with a unique prefix (e.g. `[DEBUG-a4f2]`) so cleanup is a single search
- Performance regression: measure a baseline (timing, profiler, query plan) and bisect; measure before fixing

---

## Error classification

Classify the error as:

- **Simple**
  - isolated error
  - low impact

- **Structural**
  - involves architecture
  - multiple points
  - includes absence of a correct seam for a regression test

- **Critical**
  - security
  - data
  - system flow

---

## Important

- DO NOT fix yet
- DO NOT skip investigation
- DO NOT skip the feedback loop
- DO NOT list multiple causes without ranking
- Always indicate the most likely cause
- Remove `[DEBUG-...]` instrumentation before finishing, or record in **Next steps** that it must be removed in `/execute`

---

## Mandatory output format

## Status

- Preliminary diagnosis / Waiting for data / Ready for correction

---

## Analysis

### Problem

- Clear description of the error

---

### Expected behavior

- Based on docs or rules

---

### Feedback loop

- Reproduction command (redacted)
- Observed output (red) and Phase 1 checklist
- Minimised scenario

---

### Error classification

- Simple / Structural / Critical

---

### Ranked hypotheses

- 3 to 5 hypotheses, each with the prediction that confirms or refutes it
- Result of each probe executed

---

### Most likely cause

- Only ONE (first of the ranking after probes)
- Justify with evidence
- Confidence level: low / medium / high
- What would confirm or refute

---

### Technical analysis

- Where is the problem:
  - modules
  - flow
  - logic

---

### Impact

- What can break

---

### Seam for regression test

- Correct seam available: YES / NO
- If NO: record as an architecture finding

---

### Investigation plan

- Remaining steps to validate
- Start with the most likely cause

---

## Problems

- Insufficient data
- Uncertainties
- Risks of wrong correction

If there is none:
→ None

---

## Next steps

- Request logs / access / artifact (if there is no loop)
- Validate main hypothesis
- After confirmation:
  → `/execute` (simple error) — regression test before the fix and cleanup checklist
  → `/refactor` (structural error)
  → `/plan` (complex error)
