---
name: brainstorm
description: Structured brainstorming before any implementation — explores the problem in conversational phases, generates 2 to 5 approaches with pros/cons, proposed design, risks and recommendation. Includes HARD-GATE anti-bypass, dialog with selectable options, self-review, save gate and readiness criteria (DoD). Output: Status, Analysis, Problems and Next steps. Prerequisite: /context. Next step: /prd, /spec or /plan (depending on gate). It doesn't implement anything.
license: MIT
metadata:
  author: BrunoCastro
  version: "1.3.0"
---
## Common normative reference

Mandatory application:

- `_shared/base-output.md`
- `_shared/base-preconditions.md`
- `_shared/base-degraded-mode.md`
- `_shared/target-adapter.md`
- `model-policy.md`
- Resolve these references according to `_shared/target-adapter.md` (no fallback outside the active target).

---

## System integration (CRITICAL)

This command:

- MUST be used when `/workflow` decides to → EXPLORE FIRST
- MAY be used before `/prd`, `/spec` or `/plan` when there are trade-offs or insufficient clarity
- DOES NOT replace `/prd`, `/spec` or `/plan` — prepares decision for next step
- MUST NOT invoke `/execute` or any implementation

Allowed handoff (decide at final gate):

- `/prd` — lacks product definition, scope or business criteria
- `/spec` — PRD exists, deterministic technical decision is lacking
- `/plan` — scope and approach are already clear enough to plan implementation

---

## Mandatory gate (HARD-GATE)

DO NOT invoke `/execute`, write code, scaffold project, or take any implementation action until:

1. present the complete recommendation
2. Complete Self-Review
3. get explicit user approval

This goes for **every** task, regardless of perceived complexity.

### Anti-pattern: "It's too simple to need brainstorming"

Simple tasks may be short in design (few sentences), but they **always** pass the gate. "Simple" projects are where unexamined assumptions generate the most rework.

HARD-GATE violation → status `Blocked`.

---

## Objective

Explore multiple possible approaches before defining a solution, with incremental validation and clear handoff to the next SDLC command.

---

## Model usage (ALIGNED TO MODEL-POLICY)

- **Phases 1–2 (context and approaches):** economic model by default
- **Validation in code (Serena) and comparison of trade-offs:** intermediate model when complexity ≥ medium
- **Final recommendation, proposed design and DoD:** strongest model when complexity ≥ medium or risk ≥ medium
- Escalate only when the quality of the decision justifies it

---

## Using MCP tools

If available:

### Serena MCP- Use for:
  - understand the actual structure of the code
  - identify existing patterns
  - find similar implementations
  - validate assumptions about architecture
- Prioritize:
  - find_symbol
  - find_referencing_symbols
  - search_for_pattern
  - get_symbols_overview
- Avoid:
  - assume structure without validation
  - base decisions on file names only

---

## Visual resources (optional)

Decide **per question**, not per entire session.

**Use diagram or mockup** (Mermaid, canvas or equivalent) when the content **is visual**:

- UI layout, wireframes, side-by-side comparison
- component architecture, data flow, state machine

**Use terminal/texto** when the content is conceptual:

- trade-offs, scope, success criteria, API decisions
- requirement or clarification questions

Question about UI is not automatically visual. "What does X mean in this context?" → text. "Which layout works best?" → visual.

---

## Phased process (MANDATORY)

Execute in order. Don't skip phases. Proceed only after validating the current phase.

| Phase | Objective | Typical status |
|------|----------|---------------|
| 1/4 | Context, premises and gaps | `In exploration (fase 1/4)` or `Aguardando resposta` |
| 2/4 | Approaches, pros/cons and complexity | `In exploration (fase 2/4)` or `Aguardando resposta` |
| 3/4 | Proposed design, risks, criteria and recommendation | `In exploration (fase 3/4)` or `Aguardando resposta` |
| 4/4 | Self-review, rescue gate and handoff | `In exploration (fase 4/4)` → final readiness status |

### Phase 1 — Context and gaps

- Explore `.agents`, `docs` and real code (Serena, when available)
- If the scope describes multiple independent subsystems → **decompose first** (see section below)
- Identify validated assumptions vs. not validated
- Ask **one question at a time** for remaining gaps
- Validate understanding before moving forward

### Phase 2 — Approaches

- Propose **2 to 5** different approaches
- Compare pros, cons and complexity (Low / Medium / High)
- Base on real code standards when possible
- **DO NOT** close a single solution yet

### Phase 3 — Design and recommendation- Present proposed design (scale by complexity)
- Define success criteria, risks and adherence to the project
- Register recommendation, rejected options and confidence
- Request validation of the recommendation from the user

### Phase 4 — Self-review, rescue and handoff

- Perform self-review (see section below)
- Ask save gate (if not already answered)
- Set next command: `/prd`, `/spec` or `/plan`
- Mark readiness status only after explicit approval

---

## Structured dialogue (MANDATORY)

When you need user input:

- present options in a structured and selectable dialog
- **prefer multiple choice** (A/B/C/D) instead of open-ended question
- **one question per message**
- include option `Other` when it makes sense
- if user chooses `Other` → request details afterwards (free text only at this stage)
- if answer ambiguous → repeat the same dialogue until explicit selection
- record in the analysis which option was chosen

---

## Decomposition into sub-projects

When the scope involves multiple independent subsystems (e.g. chat + billing + analytics):

1. list sub-projects with relationship and suggested order of construction
2. brainstorm **just the first** sub-project in this session
3. register the others in **Next steps** as future cycles (`brainstorm → spec/plan → execute` each)
4. DO NOT try to close recommendation for the entire system at once

---

## Work on existing codebase

Before proposing changes:

- explore existing structure and patterns (Serena when available)
- follow project conventions
- include **targeted** improvements when current code gets in the way of work (large file, blurred boundaries) — justify and keep scope focused
- DO NOT propose refactoring unrelated to the current objective

### Design for isolation and clarity

For each proposed unit, answer:

- what do you do?
- how is it used?
- what does it depend on?

Prefer smaller units with clear interfaces and single responsibility.

---

## Rules1. Build on:
   - `.agents` (technical restrictions)
   - `docs` (product objectives)
   - Serena MCP (when available, to validate the real code)
2. DO NOT choose a single solution before phase 3.
3. DO NOT implement anything.
4. Whenever necessary:
   - validate assumptions with Serena
   - avoid decisions based only on static context
5. DO NOT proceed to handoff without explicit user approval of the recommendation.
6. DO NOT invoke `/execute`, `/plan` or write code without completing the gate.

---

## Specific rules

- DO NOT assume architecture without validating it in the code
- DO NOT propose solutions that contradict existing standards
- DO NOT ask for confirmation of normative file path when the command is already running on the active target
- If Serena is available:
  - validate at least one hypothesis in real code
- If Serena is NOT available:
  - warn limitation in the analysis
- Apply YAGNI:
  - avoid overengineering and unsolicited scope
- Every recommendation must indicate the main source:
  - real code (Serena), docs, or explicit user validation

---

## Mandatory save confirmation (Phase 4)

Before marking readiness status, ASK the user:

- Want to save the brainstorm to keep the data documented?

It is mandatory to present clear options:

- Yes, save the brainstorm
- No, just show in chat

Rules:

- DO NOT mark readiness status before user response about save
- Ask the question in a structured dialogue with selectable options (not in free text)
- If the answer is ambiguous, ask again using the same options
- Register the chosen preference in the output (save or not save)
- If the user chooses to save, use default destination: `.agents/docs/brainstorm/YYYY-MM-DD-<topico>.md`
- Record the path in the **Next steps** section when saving

---

## Self-review (before readiness status)

Run inline before marking `Pronto para /prd`, `Pronto para /spec` or `Pronto para /plan`:| Check | What to look for |
|-------|--------------|
| Placeholders | TBD, TODO, incomplete or vacant sections |
| Consistency | Contradictions between approaches, design and recommendation |
| Scope | Does it fit into a single `/plan` or does it need to be broken down into sub-projects? |
| Ambiguity | Any requirements interpretable in two different ways? |

Fix issues inline. Do not mark readiness while there is an issue that compromises the handoff.

---

## Important

- If any approach violates `.agents` → DISCARD
- If in doubt → ASK (structured dialogue)
- DO NOT implement anything
- DO NOT infer behavior without evidence

---

## Produce (**Analysis** content)

Under **Analysis**, include the `###` subsections applicable to the current phase. In the final phase, include **all**:

### Problem

- What needs to be resolved

### Assumptions and gaps

- What is a validated fact
- What is a premise that has not yet been validated
- Which gaps require asking the user

### Sub-projects (when applicable)

- List of independent parts, suggested order and which is in focus in this session

### Possible approaches

- List 2 to 5 different options
- Whenever possible:
  - base on real code patterns (via Serena)

### Pros and cons

- For each approach

### Complexity

- Low / Medium / High (by approach or synthesis)

### Proposed design

- Scale by complexity: few sentences if simple; up to ~300 words if complex
- Cover when applicable:
  - affected architecture/components
  - data flow
  - error handling
  - testing strategy
  - justified collateral improvements (if any)

### Risks

- Technical or business
- Consider impact on existing code

### Success criteria

- How to measure whether the solution meets the objective
- Objective criteria (functional, technical and business, when applicable)

### Adherence to the project

- Compatible with `.agents`?
- Aligned with `docs`?
- Consistent with the current code (via Serena)?

### Recommendation

- Best option (with justification)
- Suggested handoff: `/prd`, `/spec` or `/plan` (with reason)

### Decision and rejected

- Option chosen and reason
- Discarded options and reason for discarding### Confidence in the recommendation

- Low / Medium / High

### Current phase

- Indicate process phase (e.g.: `2/4 — Abordagens`)

### Save preference

- Save / Don't save
- Path defined (when saving)

---

## Readiness Criteria (DoD)

Only use status `Pronto para /prd`, `Pronto para /spec` or `Pronto para /plan` if **ALL** of the following items are met:

- defined problem with clear scope
- premises and gaps explained
- 2 to 5 approaches compared with pros and cons
- proposed design presented (scale appropriate to complexity)
- main risks identified
- defined success criteria
- justified recommendation with explicit handoff
- rejected options recorded with reason
- self-review completed (4 checks)
- registered save preference
- explicit user approval to proceed to the next command

---

## Mandatory output format

**Always** respond with these four titles `##`, **in this order** and **with these exact names**:

1. **Status** — use only one value between:
- `In exploration (fase 1/4)`
- `In exploration (fase 2/4)`
- `In exploration (fase 3/4)`
- `In exploration (fase 4/4)`
   - `Aguardando resposta`
   - `Blocked`
   - `Pronto para /prd`
   - `Pronto para /spec`
   - `Pronto para /plan`
2. **Analysis** — main content; just use `###` to subdivide (see list above).
3. **Issues** — `.agents` violations, context gaps, unacceptable risks, HARD-GATE violation; if there is none: **None**.
4. **Next steps** — e.g.: questions to the user (structured dialogue), run `/prd`, `/spec` or `/plan`, save artifact; wait for explicit confirmation before handoff (**always** the last `##` section of the response).

Do not omit sections. Do not rename titles.