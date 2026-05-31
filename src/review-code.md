---
name: review-code
description: Evaluates technical quality of the implementation by comparing code with PRD/SPEC/PLAN. Focus on bugs, architecture, testing and readiness for production. Does not implement. Does not correct. Just analyze.
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
- reference to `/plan`
- reference to `/spec`
- code diff (when applicable)

If incomplete:
→ BLOCK

---

## Rules

1. DO NOT implement anything
2. DO NOT autocorrect
3. DO NOT assume behavior not defined in the spec
4. Just analyze
5. BLOCK if anti-compaction invariants (pt-BR + Memflow) are missing in the context
6. Apply safe continuity checklist defined in `_shared/base-preconditions.md`

---

# Assessment criteria

---

## 1. Adherence to SPEC

- follow input contracts/output?
- Is behavior correct?
- Were the rules respected?
- Is there disagreement?

---

## 2. Code quality

- clear and readable code?
- separation of responsibilities?
- duplication avoided (DRY)?
- correct typing (if applicable)?
- adequate error handling?

---

## 3. Architecture

- structure consistent with the project?
- well-defined components?
- scalable?
- performance considered?

---

## 4. Tests

- Are there tests?
- do they cover real logic?
- Do they cover edge cases?
- are they reliable (not just mocks)?

---

## 5. Security

- exposure of secrets?
- adequate input validation?
- clear security flaws?

---

## 6. Production (Readiness)

- backward compatibility considered?
- errors handled correctly?
- proper logs?
- predictable behavior?

---

## 7. Simplicity and overengineering

- Does the solution use the minimum complexity necessary?
- Is there a single-use abstraction without real need?
- is there configurability/flexibilidade added without explicit requirement?
- Is the volume of code proportional to the problem solved?

---

## Problem classification

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
- overengineering (no need for abstractions/configurations)

---

### Minor (NICE TO HAVE)

- code improvements
- readability
- optimizations

---

## Important

- This command does NOT validate memflow flow (this is the role of `/review`)
- This command does NOT replace `/review`
- This command validates the actual implementation
- DO NOT auto-execute any next step without explicit confirmation from the user

---

# Mandatory output format

## Status

- Approved / Approved with reservations / Failed

---

## Analysis

- General technical assessment of implementation
- Relevant positive points
- Adherence to `/spec` and `/plan`
- Code and architectural quality
- Test coverage and quality
- Readiness for production (risks and predictability)

---

## Problems

### Critical
- ...

### Important
- ...

### Minor
- ...

If there is none:
→ None

---

## Next steps

If APPROVED:

- ready for production
- Wait for explicit confirmation from the user before any new command

If WITH PROVISIONS:

- fix important items before merging
- Wait for explicit confirmation from the user before any new command

If FAIL:

- correct critics
- rerun `/review-code`
- Wait for explicit confirmation from the user before any new command