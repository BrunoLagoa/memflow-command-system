---
name: refactor
description: Analyzes and proposes code refactoring with deep-module vocabulary (module, interface, depth, seam, adapter, leverage, locality) — identifies shallow modules, duplication, poor readability and standards violations, applies the deletion test and presents prioritized deepening opportunities. Classifies risk (Low/Medium/High). Does not apply changes automatically; awaits explicit confirmation. Output: Status (Analysis completed/Blocked), diagnosis and proposed changes. Blocks execution if High risk without confirmation.
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
- `_shared/base-subagents.md`
- `_shared/target-adapter.md`
- `model-policy.md`

---

## Objective

Refactor code:

- keeping functional behavior
- improving quality, readability and structure
- deepening shallow modules to gain testability and agent navigability
- respecting `.agents` and `docs`

---

## Mandatory rules

1. Mandatorily follow:
   - `.agents` (technical standards and security)
   - `docs` (expected behavior)
   - `.agents/domain/GLOSSARY.md` to name modules and the area's ADRs (decisions that must not be reopened without reason)

2. DO NOT change functional behavior without explicit warning

3. DO NOT introduce new architecture without validation

---

## Model usage (ALIGNED TO MODEL-POLICY)

This command should:

- use intermediate or advanced model
- prioritize analysis quality and refactoring safety
- follow `model-policy.md` resolved by the active target (via `_shared/target-adapter.md`)

---

## Design vocabulary (use exactly)

- **Module:** anything with an interface and an implementation (function, class, package, vertical slice). _Avoid_: component, service, unit.
- **Interface:** everything a caller must know to use the module correctly — signature, invariants, call ordering, error modes, configuration, performance characteristics. _Avoid_: API, signature.
- **Implementation:** the body of code inside the module.
- **Depth:** leverage at the interface — how much behavior a caller (or test) exercises per unit of interface learned. **Deep** = a lot of behavior behind a small interface; **shallow** = interface nearly as complex as the implementation.
- **Seam:** a place where behavior can be altered without editing in that place; where the module's interface lives. _Avoid_: boundary.
- **Adapter:** a concrete thing that satisfies an interface at a seam (role, not substance).
- **Leverage:** what callers get from depth.
- **Locality:** what maintainers get from depth — change, bugs and verification concentrated in one place.

---

## Principles

- **Depth is a property of the interface**, not of the implementation; a deep module may have small, swappable internal parts (internal seams).
- **Deletion test:** imagine deleting the module. If complexity vanishes, it was a pass-through; if it reappears spread across N callers, it was earning its keep.
- **The interface is the test surface:** callers and tests cross the same seam; wanting to test "behind" the interface signals a module of the wrong shape.
- **One adapter = hypothetical seam; two adapters = real seam.** Do not introduce a seam unless something actually varies across it.
- Prefer: accepting dependencies over creating them; returning results over producing side effects; small interfaces.

---

## Exploration (deepening opportunities)

Scope before scanning (YAGNI):

- if the user named a direction (module, subsystem, pain point) → follow it
- otherwise → walk the history (`git log --oneline`) to find **hot spots** (files/areas that change often) and start there

Friction questions:

- does understanding one concept require bouncing between many small modules?
- are there shallow modules (interface nearly as complex as the implementation)?
- were pure functions extracted just for testability while the bugs hide in how they are called (no locality)?
- do coupled modules leak across their seams?
- which parts are untested, or hard to test through their current interface?

Apply the deletion test to every suspected shallow module.

For each candidate, present:

- **Files/modules** involved
- **Problem:** why the current shape causes friction
- **Solution:** what would change, in plain language
- **Benefits:** in terms of locality and leverage, and how tests would improve
- **Recommendation strength:** `Forte` / `Vale explorar` / `Especulativa`
- **ADR conflict** (when any): flag it explicitly and only propose it if the friction justifies reopening the decision

Close with the **top recommendation** (which candidate to tackle first and why) and ask the user which one to explore. DO NOT propose interfaces before the choice.

After the choice:

- run question rounds on constraints, dependencies, the shape of the deepened module, what sits behind the seam and which tests survive
- name the deepened module with glossary terms; new term → record with confirmation (`_shared/base-domain-model.md`)
- if the user rejects the candidate with a load-bearing reason → offer an ADR so future reviews do not suggest it again

---

## Subagent orchestration

Apply `_shared/base-subagents.md`. Only when the `/workflow` decision is `Orquestração: Com subagents`:

- **Fact-finding:** a read-only subagent walks the code (hot spots and friction questions) and reports candidates with evidence
- **Parallel design:** for the chosen candidate, 2 to 3 subagents design the interface in radically different ways (e.g. minimal, use-case oriented, extensibility oriented); compare on depth, locality and seam placement
- the final choice, risks and proposal stay in the main context

Without subagents → explore and compare in the main context.

---

## Mandatory analysis

Before any refactoring, identify:

### Current problem

- Duplicate code
- Low readability
- Violation of standards
- Unnecessary complexity
- Shallow modules (deletion test)

---

### Applicable rules

- Which `.agents` rules are being violated or not followed
- Standards that should be applied
- ADRs of the area that constrain the proposal

---

### Refactoring strategy

- How the code will be improved
- Which approach will be used (e.g. deepen module, extract/inline function, move seam, separate responsibility)
- Wide refactor → sequence as expand → migrate → contract (see `/plan`)

---

### Proposed changes

- Clear and objective list of what will be changed

---

### Risks

Classify:

- Low
- Medium
- High

And explain:

- what can break
- possible impact

---

## Risk validation

- If risk = HIGH:
  - WARN
  - DO NOT run automatically
  - Wait for confirmation

- If there is a violation of `.agents`:
  - STOP
  - Explain the problem

---

## Execution blocking

This command MUST NOT apply changes automatically.

Always:

- present complete analysis
- wait for explicit confirmation from the user

---

## Important

- DO NOT perform refactoring automatically
- DO NOT change behavior without authorization
- This command is just analysis + proposal

---

## Mandatory output format

ALWAYS respond with:

## Status

- Analysis completed / Blocked

---

## Analysis

- Diagnosis of current code
- Deepening candidates (with recommendation strength) and top recommendation
- Problems found
- Current quality
- Orquestração: Com subagents / Sem subagents / Sem subagents (fallback)

---

## Problems

- Clear list of points that need refactoring
- If there is none: None

---

## Next steps

- Choose the candidate to explore
- Confirm whether to apply refactoring
- Or adjust strategy
