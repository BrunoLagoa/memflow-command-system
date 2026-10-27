---
description: It is not an executable command. Shared domain model base (glossary and ADRs).
license: MIT
hidden: true
metadata:
  author: BrunoCastro
  version: "1.0.0"
---

# Domain model common base (normative reference)

Apply this block in commands that read or refine the project language (`/context`, `/brainstorm`, `/spec`, `/plan`, `/execute`, `/test-plan`, `/debug`, `/review-code`).

Goal: keep a short and precise **ubiquitous language** between user, agent and code, and record hard-to-reverse decisions without duplicating Memflow memory.

---

## Layout (MANDATORY)

- Glossary: `.agents/domain/GLOSSARY.md`
- ADRs: `.agents/domain/adr/NNNN-slug.md` (sequential numbering: `0001-...`, `0002-...`)
- Create files **on demand**: the glossary only when the first term is resolved; `adr/` only when the first ADR is approved.
- To find the next ADR number, read `.agents/domain/adr/` and increment the highest existing number.

---

## Reading (all commands applying this block)

- If `.agents/domain/GLOSSARY.md` exists:
  - use its terms in questions, names, task titles, specs, tests and reports
  - DO NOT use terms listed under `_Avoid_`
- If `.agents/domain/adr/` exists:
  - read ADR titles and open only the ADRs of the touched area
  - DO NOT reopen a decision recorded in an ADR without explicitly flagging the conflict (e.g. "this contradicts ADR-0003; worth reopening because…")
- Missing glossary or ADRs **does not block** execution.

---

## Active refinement (`/brainstorm`, `/spec`, `/plan`, `/debug`)

During the session:

- **Challenge against the glossary:** when the user uses a term that conflicts with the glossary, point it out immediately ("the glossary defines X as A, but you seem to mean B — which is right?").
- **Sharpen fuzzy language:** when a term is vague or overloaded, propose a canonical term ("is 'account' here the Customer or the User?").
- **Stress-test with concrete scenarios:** invent edge-case scenarios that force precision on the boundaries between concepts.
- **Cross-reference with code:** when the user states how something works, check whether the code agrees and surface contradictions.

---

## Glossary format

```md
# {Context name}

{One or two sentences about what this context is.}

## Language

**Order**:
{One or two sentence definition — what it IS, not what it does.}
_Avoid_: purchase, transaction
```

Rules:

- Be opinionated: pick one term and list synonyms under `_Avoid_`.
- Short definitions (1–2 sentences).
- Include only terms specific to the project domain (not generic programming concepts).
- Group under subheadings when natural clusters emerge.
- The glossary does NOT contain implementation details, specs or drafts.

---

## ADRs (offer sparingly)

Offer an ADR **only** when all three criteria are true:

1. **Hard to reverse** — changing your mind later has meaningful cost
2. **Surprising without context** — a future reader would ask "why did they do it this way?"
3. **Result of a real trade-off** — there were genuine alternatives and one was picked for specific reasons

If any is missing → DO NOT offer an ADR.

Template:

```md
# {Short decision title}

{1–3 sentences: context, what was decided and why.}
```

Optional sections (only when they add value): `Status` (`proposed | accepted | deprecated | superseded by ADR-NNNN`), `Considered options`, `Consequences`.

---

## Writing with confirmation (CRITICAL)

- NEVER write to `.agents/domain/` silently.
- Group resolved terms and candidate ADRs at the end of each round/phase and ask in a structured dialog:
  - Yes, record in glossary/ADR
  - Do not record now
  - Adjust before recording
- Record in `## Analysis` the terms and ADRs actually written.

---

## Relationship with Memflow memory

- `.agents/memory/decisions.md` remains the scored decision memory (source of reuse across sessions).
- An ADR is the **durable, human-readable** record of decisions that pass the three criteria.
- When an ADR is created for a decision existing in `decisions.md`, the decision must reference the ADR (e.g. `ADR: .agents/domain/adr/0002-slug.md`) — without duplicating content.
- Glossary and ADRs do not replace `/memory-save`.

---

## Precedence rule

- This file defines the common domain model pattern.
- Commands can extend these rules.
- Non-overwriteable invariants:
  - writing to `.agents/domain/` only with explicit confirmation
  - ADR only when all three criteria are true
  - glossary without implementation details
  - missing glossary/ADRs does not block execution
