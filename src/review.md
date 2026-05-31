---
name: review
description: Intelligent system quality validation before optional hard validation — assesses adherence to .agents, security, architecture, product (docs), system flow, and model usage. Acts as governance QA. Does not correct. Can be complemented by /review-enforce-rules.
license: MIT
metadata:
  author: BrunoCastro
  version: "2.3.0"
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

Evaluate whether the solution:

- follows `.agents` (technical rules and safety)
- is aligned with `docs` (product)
- respects the project architecture
- correctly follows the system flow
- is in accordance with `model-policy.md` of the active target

This command acts as **system governance validation**, ensuring that execution respects the memflow rules and structure.

---

## Role in the system

- DOES NOT validate code deeply (this is `/review-code`'s responsibility)
- Does NOT implement anything
- DOES NOT automatically correct
- Acts as **QA of the flow, architecture and rules**

---

## Analysis basis

Mandatory use:

- `.agents/**/*` → technical rules (when available)
- `docs/**/*` → product
- `model-policy.md` of active target
- `/workflow` decisions
- `/plan` (when applicable)
- execution carried out via `/execute`

---

## Rules

1. DO NOT implement anything
2. DO NOT suggest direct execution
3. DO NOT autocorrect
4. Just analyze and validate
5. DO NOT continue without valid anti-compaction invariants in the context

---

# Assessment criteria

---

## 1. Adherence to the rules

- Follow `.agents`?
- Does it violate any technical rules?

---

## 2. Security

- Is there an exhibition of secrets?
- Is client/server correct?
- Were safety rules respected?

---

## 3. Architecture

- Consistent with the project standard?
- Do you reuse existing components?
- Avoid duplication?
- Does it follow defined standards?

---

## 4. Product

- Aligned with `docs`?
- Was expected behavior respected?

---

## 5. System flow

- Was `/workflow` followed correctly?
- Was `/plan` used when necessary?
- Did `/execute` respect the plan?
- Was `/execute` started only after explicit decision by `/workflow`?
- Was there a system bypass?
- Were anti-compaction invariants (pt-BR + Memflow) valid before execution?

---

## 6. Execution strategy

- Was planning done correctly?
- Complexity handled appropriately?
- Did the execution respect the expected level?

---

## 7. Use of template

- Model suitable for complexity?
- Planning vs coherent execution?
- Excessive use of advanced model?

---

## 8. Scope of changes (surgical check)

- Were the changes restricted to the order?
- Does each changed file have a direct link to the request?
- Was there adjacent refactoring without explicit need?

---

# Problem classification

---

## Critical (MUST FIX)

- violation of `.agents`
- security breach
- system flow break
- execution outside the correct process

---

## Important (SHOULD FIX)

- architectural inconsistency
- misalignment with docs
- incorrect use of template
- unjustified out-of-scope changes

---

## Minor (NICE TO HAVE)

- structural improvements
- organization adjustments

---

# Automatic disapproval criteria

Reject if any:

- violation of `.agents`
- security breach
- execution outside the flow
- lack of planning when necessary
- critical inconsistency with docs
- inappropriate use of template
- anti-compaction invariants fail (pt-BR + Memflow)

Observation:

- absence of `.agents` DOES NOT fail automatically (degraded mode)

---

# Important

- This command does NOT validate code deeply
- This command does NOT replace `/review-code`
- Acts as system QA

---

# Mandatory output format

## Status

- Approved / Approved with reservations / Failed

---

## Analysis

- Overall rating
- Solution quality
- Positive points
- Alignment with:
  - rules
  - architecture
  - flow
  - model

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

If `.agents` is missing:

- mark as limitation (not violating)

---

## Risk

- Low / Medium / High

Based on:

- impact on the system
- impact on flow
- impact on production

---

## Next steps

If APPROVED:

- Optional run `/review-enforce-rules`
- Run `/review-code` before production
- Wait for explicit confirmation from the user before any new command

---

If APPROVED WITH PROVISIONS:

- You can follow the flow
- Fix important items before production
- Run `/review-code`
- Wait for explicit confirmation from the user before any new command

---

If FAIL:

- Fix critical issues
- Rerun `/review`
- After approval, execute `/review-code`
- Wait for explicit confirmation from the user before any new commandcommand