---
name: brainstorm
description: Structured brainstorming before any implementation — explores the problem in conversational phases, generates 2 to 5 approaches with pros/cons, proposed design, risks and recommendation. Includes HARD-GATE anti-bypass, questions in rounds over the decision frontier with selectable options and a recommended answer, domain model refinement (glossary and ADRs), map mode for multi-session efforts, optional subagents for fact-finding, self-review, save gate and readiness criteria (DoD). Output: Status, Analysis, Problems and Next steps. Prerequisite: /context. Next step: /prd, /spec or /plan (depending on gate). It doesn't implement anything.
license: MIT
metadata:
  author: BrunoCastro
  version: "1.5.0"
---
## Common normative reference

Mandatory application:

- `_shared/base-output.md`
- `_shared/base-preconditions.md`
- `_shared/base-degraded-mode.md`
- `_shared/base-domain-model.md`
- `_shared/base-subagents.md`
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
- Look up on your own every **fact** available in code, docs or MCP (see Question rounds)
- Ask the remaining **decisions** in **frontier rounds** (see Question rounds)
- Apply domain refinement: challenge terms against the glossary and sharpen fuzzy language
- Validate understanding before moving forward

### Phase 2 — Approaches

- Propose **2 to 5** different approaches
- Compare pros, cons and complexity (Low / Medium / High)
- Base on real code standards when possible
- **DO NOT** close a single solution yet

### Phase 3 — Design and recommendation

- Present proposed design (scale by complexity)
- Define success criteria, risks and adherence to the project
- Register recommendation, rejected options and confidence
- Request validation of the recommendation from the user

### Phase 4 — Self-review, save and handoff

- Perform self-review (see section below)
- Confirm recording of resolved domain terms and candidate ADRs (see Domain model)
- Ask save gate (if not already answered)
- Set next command: `/prd`, `/spec` or `/plan`
- Mark readiness status only after explicit approval

---

## Structured dialogue (MANDATORY)

When you need user input:

- present options in a structured and selectable dialog
- **prefer multiple choice** (A/B/C/D) instead of open-ended question
- **one round per message** (see Question rounds); each question in the round has its own options
- mark the recommended option with `(Recomendado)` and list it first
- include option `Other` when it makes sense
- if user chooses `Other` → request details afterwards (free text only at this stage)
- if answer ambiguous → repeat the same dialogue until explicit selection
- record in the analysis which option was chosen

---

## Question rounds (decision frontier)

Map open questions as a **decision tree**: each decision opens the decisions that depend on it.

- **Frontier** = decisions whose prerequisites are already settled (can be asked now without guessing answers not yet heard).
- Ask **the whole frontier in one round**, numbering the questions and including a recommended answer for each.
- A question whose answer depends on another still open in the same round belongs to a **later** round.
- After each round, recompute the frontier with the answers received and move to the next one.
- Practical limit: up to 4 questions per round; if the frontier is larger, prioritize those that unblock the most decisions.

**Facts are the agent's job; decisions are the user's.**

- NEVER ask the user something that can be found in the code, `.agents`, `docs` or MCP.
- While a fact is being looked up, ask only the decisions that do not depend on it.

Round format (text, when the target has no native question tool):

```
❓ **P1 — <title>**: <short context of the decision>
  A) <option> (Recomendado)
  B) <option>
  C) Outra

❓ **P2 — <title>**: ...
```

- When the target offers a native question tool with selectable options, use it with the questions of the round.
- Phase 1 ends when the frontier is empty: every branch visited, nothing silently assumed.

---

## Domain model

Apply `_shared/base-domain-model.md` in **active refinement** mode:

- use the vocabulary of `.agents/domain/GLOSSARY.md` in questions, approaches and design
- challenge conflicting terms and propose canonical terms during the rounds
- cross-reference user statements with the real code
- respect existing ADRs; explicitly flag any approach that contradicts an ADR
- at the end of each phase (and mandatorily in phase 4), list resolved terms and candidate ADRs and ask for confirmation before writing

---

## Decomposition into sub-projects

When the scope involves multiple independent subsystems (e.g. chat + billing + analytics):

1. list sub-projects with relationship and suggested order of construction
2. brainstorm **just the first** sub-project in this session
3. register the others in **Next steps** as future cycles (`brainstorm → spec/plan → execute` each)
4. DO NOT try to close recommendation for the entire system at once

## Map mode (multi-session effort)

For large, foggy efforts that **do not fit in one session** (greenfield, very large feature), where the path to the destination is not visible yet. DO NOT use for a well-scoped feature — in that case, use the normal brainstorm or the decomposition into sub-projects.

### Activation

- Propose in a structured dialog: `Ativar modo mapa` / `Seguir com brainstorm normal (Recomendado quando cabe em uma sessão)`.
- NEVER activate automatically.
- The map is a saved artifact: create files only after explicit confirmation.

### Artifacts

- Map: `.agents/docs/maps/<effort>/map.md`
- Decision tickets: `.agents/docs/maps/<effort>/tickets/NN-slug.md` (numbered from `01`)

Map body (an index, not a store — the decision lives in the ticket):

```md
## Destino
<what reaching the end of this map looks like: spec, decision or change; 1–2 lines>

## Notas
<domain, commands every session should consult, standing preferences for this effort>

## Decisões até agora
- [<resolved ticket title>](tickets/NN-slug.md): <one-line gist of the answer>

## Ainda não especificado
<fog: questions you can sense but cannot phrase precisely yet>

## Fora de escopo
<work consciously excluded from this effort, with the reason>
```

Ticket body:

```md
# NN — <title>

Tipo: pesquisa | protótipo | entrevista | tarefa
Bloqueado por: NN, NN | Nenhum
Status: aberto | em andamento | resolvido

## Pergunta
<the decision or investigation this ticket resolves>

## Resposta
<filled in on resolution>
```

### Ticket types

- **pesquisa** (agent alone): read docs, APIs or local sources to get a fact a decision depends on; with subagents, one subagent per ticket.
- **protótipo** (with the user): cheap, throwaway artifact to react to ("how should it look/behave?").
- **entrevista** (with the user, default): question rounds + domain model.
- **tarefa** (agent or user): manual work that must happen before a decision (e.g. get access, create an account to evaluate an API); the answer records what was done and resulting facts.

The agent NEVER answers for the user in `entrevista` or `protótipo` tickets.

### Rules

- **Plan, don't do:** each ticket produces a decision, not a deliverable.
- **One ticket per session** (except `pesquisa`, which may run in parallel).
- **Fog or ticket?** If the question can already be phrased precisely (even if blocked) → ticket; otherwise → `Ainda não especificado`.
- **Out of scope** never graduates into a ticket; a ticket that turns out beyond the destination is closed and recorded in `Fora de escopo`.
- Refer to maps and tickets **by title**, never by a bare number.
- Map frontier: `aberto` tickets whose `Bloqueado por` is all `resolvido`.

### Invocations

**Chart** (first session):

1. define the **destination** with question rounds + domain model
2. a **breadth-first** round over the whole space, surfacing open decisions and the first possible steps
3. if there is no fog (the way is already clear and fits in one session) → do not create a map; go back to the normal brainstorm
4. with confirmation, create `map.md` and the tickets that can already be specified; wire `Bloqueado por` in a second pass
5. do not resolve tickets in this session (except `pesquisa` with subagents)

**Advance** (following sessions, given the map):

1. load `map.md` (low-resolution view)
2. pick the ticket named by the user or the first on the frontier; mark `em andamento` before working
3. resolve it according to its type; fill `## Resposta`; mark `resolvido`
4. add one line to `Decisões até agora`
5. graduate fog that became specifiable into new tickets; update or close invalidated tickets

### Handoff

- When there is no fog and no open tickets → `Pronto para /spec` (`/spec` in synthesis mode consolidates the map's decisions).
- If the effort turns out small → `Pronto para /plan`.

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

## Rules

1. Build on:
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
| Language | Do the terms used match the glossary? Is there a vague or overloaded term left unresolved? |

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

### Domain language

- Resolved terms (canonical and `_Avoid_`)
- Proposed and recorded ADRs (or reason for not proposing)

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
- self-review completed (5 checks)
- resolved domain terms recorded or explicitly postponed
- registered save preference
- explicit user approval to proceed to the next command

---

## Subagent orchestration

Apply `_shared/base-subagents.md`. Only when the `/workflow` decision is `Orquestração: Com subagents`:

- **Fact-finding:** send read-only exploration subagents for facts the rounds need (code structure, existing patterns, similar implementations, external docs)
- while they run, ask the user only the frontier decisions that do not depend on those facts
- verify findings in the code before using them in approaches or design
- **Map mode:** `pesquisa` tickets can be resolved by subagents in parallel (one per ticket), without deciding anything for the user
- decisions, recommendations and gates stay in the main context

Without subagents → run everything in the main context.

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
   - `Mapa atualizado` (map mode: session closed with the map saved)
2. **Analysis** — main content; just use `###` to subdivide (see list above).
3. **Issues** — `.agents` violations, context gaps, unacceptable risks, HARD-GATE violation; if there is none: **None**.
4. **Next steps** — e.g.: questions to the user (structured dialogue), run `/prd`, `/spec` or `/plan`, save artifact; wait for explicit confirmation before handoff (**always** the last `##` section of the response).

Do not omit sections. Do not rename titles.