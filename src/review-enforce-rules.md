---
name: review-enforce-rules
description: Additional hard validation (optional/recomendada) for critical scenarios — validates full compliance with .agents, security client/server, architecture, system flow, and `model-policy.md` of the active target (via `_shared/target-adapter.md`). Exclusive output: OK or BLOCKED. Any doubt or ambiguity = BLOCKED. Does not relax rules. Run after /review when necessary.
license: MIT
metadata:
  author: BrunoCastro
  version: "1.2.0"
---

Rigorously validate any code, plan, decision, or execution against project rules.

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

Ensure that:

- no `.agents` rules were violated
- the implementation is secure
- architecture was respected
- the system workflow was followed correctly
- the use of templates is aligned with `model-policy.md` of the active target (via `_shared/target-adapter.md`)

This is an **optional hard gate**, recommended before completion of higher risk or critical tasks.

---

## Important

- This command is optional hard validation
- DO NOT allow continuation with doubts
- DO NOT partially approve
- DO NOT ignore inconsistencies
- Must ensure total system consistency

This command complements previous validations with stricter criteria.

---

## Validation basis

Source of absolute truth:

- `.agents/**/*` (when available)

Complementary:

- `docs/**/*`
- `model-policy.md` of the active target (via `_shared/target-adapter.md`)
- `/workflow` decisions
- plan (`/plan`)
- execution (`/execute`)

---

## Critical rules

1. DO NOT accept violations
2. DO NOT relax rules
3. DO NOT assume implicit behavior
4. DO NOT validate as OK if anti-compaction invariants (pt-BR + Memflow) are missing/falhos
5. If there is **any doubt or ambiguity**:

→ consider it a violation
→ status = **BLOCKED**

---

## Mandatory checks

### Technical rules

- Code follows `.agents`?
- Were defined standards respected?

---

### Security (CRITICAL)

- Is there an exhibition of secrets?
- Correct client/server separation?
- Respect `.agents/rules/client-server-security.md`?

---

### Architecture

- Structure consistent with the project?
- Does it follow the stack standards defined in `.agents`?
- Reusing existing code?
- Lack of duplication?

---

### System flow (CRITICAL)

- Was `/workflow` used?
- Was the decision respected?
- `/execute` only started after an explicit decision by `/workflow`?
- Was `/plan` used when necessary?
- Did `/execute` follow the flow correctly?
- Was there a system bypass?
- Were anti-compaction invariants (pt-BR + Memflow) valid?

---

### Execution strategy

- Was planning carried out when necessary?
- Did execution occur consistently?
- Was there execution without context or without a plan?

---

### Model usage (ALIGNED TO MODEL-POLICY)

- Was the model consistent with the complexity?
- Did planning use an appropriate model?
- Did the execution use an economic model?
- Was escalation applied correctly?
- Was there misuse of advanced model?

---

### Code quality

- Does it follow the project's static typing and verification standards (as per `.agents`)?
- Clean and readable code?
- No duplicate logic?

---

## Blocking criteria

Status = **BLOCKED** if any:

- violation of `.agents`
- security breach
- architectural inconsistency
- system flow break
- lack of planning when necessary
- incorrect use of template (against `model-policy.md` of active target via `_shared/target-adapter.md`)
- unresolved ambiguity
- failure of anti-compaction invariants (pt-BR + Memflow)

Observation:

- absence of `.agents`, alone, does NOT automatically block; operate in degraded mode with explicit warning

---

## Mandatory output format

**Always** respond with these four titles `##`, **in this order** and **with these exact names**:

1. **Status** — `OK` or `BLOQUEADO` only
2. **Analysis** — clear summary of what was validated
3. **Issues** — objective list of violations or concerns
4. **Next steps** — mandatory actions for correction (always the **last** section `##` of the response)

Do not omit sections
Do not rename titles
Do not use other main `##`

In **Problems**, list each violation found, each unresolved question and validation limitations in degraded mode; if there is none → **None**.

In **Next steps**: if **BLOCKED**, list mandatory corrections and indicate actions such as `/plan`, `/execute`, `/debug`, `/refactor` or user clarification; if **OK** → you can continue.
Always include that any new command depends on explicit confirmation from the user.
