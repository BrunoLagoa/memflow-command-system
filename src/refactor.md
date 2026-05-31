---
name: refactor
description: Analyzes and proposes code refactoring — identifies duplication, poor readability, and standards violations. Classifies risk (Low/Mmedium/Alto). Does not apply changes automatically; awaits explicit confirmation. Output: Status (Analysis completed/Bloqueado), diagnosis and proposed changes. Blocks execution if High risk without confirmation.
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
- `_shared/target-adapter.md`
- `model-policy.md`

---

## Objective

Refactor code:

- maintaining functional behavior
- improving quality, readability and structure
- respecting `.agents` and `docs`

---

## Mandatory rules

1. Mandatory to follow:
   - `.agents` (technical standards and safety)
   - `docs` (expected behavior)

2. DO NOT change functional behavior without explicit warning

3. DO NOT introduce new architecture without validation

---

## Model usage (ALIGNED TO MODEL-POLICY)

This command should:

- use intermediate or advanced model
- prioritize analysis quality and refactoring security
- follow `model-policy.md` resolved by active target (via `_shared/target-adapter.md`)
- resolve `model-policy.md` with the active target rules (via `_shared/target-adapter.md`)

---

## Mandatory analysis

Before any refactoring, identify:

### Current problem

- Duplicate code
- Low readability
- Standards violation
- Unnecessary complexity

---

### Applicable rules

- Which `.agents` rules are being violated or not followed
- Standards that should be applied

---

### Refactoring strategy

- How the code will be improved
- What approach will be used (e.g. function extraction, simplification, separation of responsibility)

---

### Proposed changes

- Clear and objective list of what will be changed

---

### Risks

Sort:

- Low
- Average
- High

And explain:

- what can break
- possible impact

---

## Risk validation

- If risk = HIGH:
  - TO WARN
  - DO NOT run automatically
  - Wait for confirmation

- If there is a violation of `.agents`:
  - TO STOP
  - Explain the problem

---

## Execution blocking

This command should NOT apply changes automatically.

Always:

- present complete analysis
- wait for explicit confirmation from the user

---

## Important

- DO NOT perform refactoring automatically
- DO NOT change behavior without authorization
- This command is for analysis + proposal only

---

## Mandatory output format

ALWAYS respond with:

## Status

- Analysis completed / Locked

---

## Analysis

- Current code diagnosis
- Problems encountered
- Current quality

---

## Problems

- Clear list of points that need refactoring
- If none: None

---

## Next steps

- Confirm whether to apply refactoring
- Or adjust strategy
