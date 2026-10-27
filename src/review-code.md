---
name: review-code
description: Evaluates technical quality of the implementation on two independent axes over the diff since a fixed point — Standards (documented repo standards + code smell baseline) and Spec (adherence to PRD/SPEC/PLAN, extra scope and wrong implementation). Focus on bugs, architecture, testing and readiness for production. Does not implement. Does not correct. Just analyzes.
license: MIT
metadata:
  author: BrunoCastro
  version: "1.4.0"
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

Validate the technical quality of the implementation:

- adherence to `/spec` and `/plan`
- code quality
- architecture
- tests
- readiness for production

This command acts as **final technical validation before production**.

---

## Expected input

- description of what was implemented
- **fixed point** of the diff (commit, branch, tag, `main`, `HEAD~N`)
- reference to `/plan`
- reference to `/spec` (or approved PRD/brainstorm)

If the description or the fixed point is missing:
→ BLOCK and request it

If there is no spec/plan:
→ run only the **Standards** axis and record "no spec available" on the **Spec** axis

---

## Fixed point (MANDATORY)

Before evaluating:

- validate that the fixed point resolves (`git rev-parse <fixed-point>`)
- capture the diff once: `git diff <fixed-point>...HEAD` (three dots, compares against the merge-base)
- list commits: `git log <fixed-point>..HEAD --oneline`
- invalid ref or empty diff → BLOCK here, before any analysis

When there is no git, use the provided diff/description and record the limitation.

---

## Rules

1. DO NOT implement anything
2. DO NOT auto-fix
3. DO NOT assume behavior not defined in the spec
4. Just analyze
5. BLOCK if anti-compaction invariants (pt-BR + Memflow) are missing in the context
6. Apply safe continuity checklist defined in `_shared/base-preconditions.md`
7. Evaluate both axes **separately**; DO NOT merge or re-rank findings across axes

---

# Axis 1 — Standards

Question: does the code follow this repository's standards?

## Standards sources

- search every file that documents how code should be written (e.g. `CODING_STANDARDS.md`, `CONTRIBUTING.md`, `.agents/rules/**`, lint configs)
- `CODING_STANDARDS.md` and `CONTRIBUTING.md`, when they exist, are mandatory on the list
- vocabulary from `.agents/domain/GLOSSARY.md` and ADRs of the area (current names and decisions)
- skip what tooling already enforces (formatter, linter, typecheck)

## Code smell baseline (always applied)

Rules:

- **the repo overrides:** a documented repo standard always wins; where it endorses something the baseline would flag, suppress the smell
- **always a judgement call:** each smell is a labelled heuristic ("possible Feature Envy"), never a hard violation

Smells (what it is → how to fix):

- **Mysterious Name:** name does not reveal what it does/holds → rename
- **Duplicated Code:** same logic in more than one hunk of the diff → extract the shared shape
- **Feature Envy:** method reaches into another object's data more than its own → move it next to the data
- **Data Clumps:** the same fields/params travel together → bundle them into one type
- **Primitive Obsession:** primitive standing for a domain concept → its own type
- **Repeated Switches:** same `switch`/`if` on the same type in several places → polymorphism or a shared map
- **Shotgun Surgery:** one logical change forces scattered edits → gather what changes together
- **Divergent Change:** one module edited for unrelated reasons → split by reason to change
- **Speculative Generality:** abstraction/params/hooks the spec does not need → delete
- **Message Chains:** long `a.b().c().d()` navigation → hide behind one method
- **Middle Man:** class/function that only delegates → call the target directly
- **Refused Bequest:** subclass ignores most of what it inherits → composition

## Standards axis criteria

### Code quality

- clear and readable code?
- separation of responsibilities?
- duplication avoided (DRY)?
- correct typing (if applicable)?
- adequate error handling?

### Architecture

- structure consistent with the project?
- well-defined components?
- scalable?
- performance considered?

### Tests

- are there tests?
- do they cover real logic at the agreed seams?
- do they cover edge cases?
- are they reliable (not just mocks, not tautological, not implementation-coupled)?

### Security

- exposure of secrets?
- adequate input validation?
- clear security flaws?

### Production (Readiness)

- backward compatibility considered?
- errors handled correctly?
- proper logs (no leftover `[DEBUG-...]` instrumentation)?
- predictable behavior?

### Simplicity and overengineering

- does the solution use the minimum complexity necessary?
- is there a single-use abstraction without real need?
- is there configurability/flexibility added without explicit requirement?
- is the volume of code proportional to the problem solved?

---

# Axis 2 — Spec

Question: does the code faithfully implement what the spec/plan asked for?

Report, **quoting the spec line** for each finding:

- (a) requirements asked for that are **missing or partial**
- (b) behavior in the diff that **was not asked for** (extra scope)
- (c) requirements that look implemented but with a **wrong implementation**

Also check:

- does it follow input/output contracts?
- were rules and states respected?
- were the spec's test seams and testing decisions followed?

---

## Why two axes

- code that follows every standard but implements the wrong thing → **Standards pass, Spec fail**
- code that does exactly what was asked but breaks conventions → **Spec pass, Standards fail**

Reporting them separately stops one axis from masking the other.

---

## Problem classification (within each axis)

### Critical (MUST FIX)

- bugs
- security flaws
- functionality breakdown
- spec violation

---

### Important (SHOULD FIX)

- architectural problems
- lack of relevant tests
- insufficient error handling
- overengineering (unneeded abstractions/configurations)
- extra scope not requested

---

### Minor (NICE TO HAVE)

- code improvements
- readability
- optimizations
- baseline smells (judgement calls)

---

## Important

- This command does NOT validate memflow flow (this is the role of `/review`)
- This command does NOT replace `/review`
- This command validates the actual implementation
- Refactors suggested here are the refactor stage of the TDD cycle (not part of `/execute`'s red → green)
- DO NOT auto-execute any next step without explicit confirmation from the user

---

# Mandatory output format

## Status

- Approved / Approved with reservations / Failed
- Rule: any Critical on any axis → Failed; any Important → at most Approved with reservations

---

## Analysis

### Fixed point

- ref, evaluated commits and diff command used

### Standards axis

- standards sources found
- assessment of quality, architecture, tests, security, readiness and simplicity
- identified smells (labelled as judgement calls)

### Spec axis

- spec source used (or "no spec available")
- missing/partial requirements, extra scope and wrong implementation (with quotes)

### Summary

- total findings per axis and the worst issue **within each axis** (without picking a winner across axes)

---

## Problems

### Standards

#### Critical
- ...

#### Important
- ...

#### Minor
- ...

### Spec

#### Critical
- ...

#### Important
- ...

#### Minor
- ...

If there is none:
→ None

---

## Next steps

If APPROVED:

- ready for production
- Wait for explicit confirmation from the user before any new command

If WITH RESERVATIONS:

- fix important items before merging
- Wait for explicit confirmation from the user before any new command

If FAILED:

- fix critical items
- rerun `/review-code`
- Wait for explicit confirmation from the user before any new command
