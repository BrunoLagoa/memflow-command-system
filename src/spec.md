---
name: spec
description: Transforms PRD into detailed, deterministic and executable technical specification. Defines system behavior, input/saoutput contracts, flows, states and rules. Basis for /plan — no assumptions. In case of ambiguity or technical trade-off, it can present options and even block the user's decision. Does not implement. Blocks if there is unresolved ambiguity.
license: MIT
metadata:
  author: BrunoCastro
  version: "2.2.0"
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

Transform a PRD into a technical specification:

- clear
- deterministic
- unambiguously
- validatable
- ready to run via `/plan`

---

## System integration

This command:

- receives input from `/prd`
- serves as the basis for `/plan`
- defines technical behavior of the system
- DOES NOT implement

---

## Document scope

- Detail **how** the system behaves technically (contracts, states, flows).
- Do not repeat PRD business storytelling; **reference** the PRD when the decision is already there.
- Do not include business metrics or non-actionable narrative for implementation.

---

## Template usage

- use intermediate or higher model
- prioritize absolute technical precision
- avoid inferences

---

## Mandatory precondition

- PRD must be complete
- If PRD is incomplete → BLOCK

## Mandatory save confirmation (BEFORE any spec generation)

Before starting the analysis and creation of the specification, ASK the user:

- Do you want to save the specification that will be created to maintain documented data?

It is mandatory to present clear options:

- Yes, save the specification
- No, just show in chat

Rules:

- DO NOT start spec generation before user response
- Ask the question in a structured dialogue with selectable options (not in free text)
- If the answer is ambiguous, ask again using the same options
- Maintain the same structured dialogue format in repetition attempts
- Record the chosen preference in the output (save or not save)
- If the user chooses to save, define and register the documentation destination before continuing

### Technical ambiguity, trade-offs and user choice

When there is **more than one valid technical solution** (e.g. protocol, persistence, idempotence, API granularity, error strategy) or **technical gap** not covered by the PRD:

- **Do not** choose alone without alignment when the trade-off impacts observable behavior or contracts.
- Present **2 to 4 options** with brief pros and cons; may include **reasoned recommendation**, without replacing the user's decision.
- **BLOCK** the generation (or continuation) of the specification until the user **chooses an option** or **defines explicit decision criteria**.

If the decision is already **explicit in the PRD** → follow the PRD; do not reopen as ambiguity.

---

# Specification Structure

---

## 1. Technical objective

- What will be built (technical overview)
- Expected result of the system

---

## 2. Solution architecture

### Components
- services
- modules
- responsibilities

### Data flow
- source → processing → output

---

## 3. Technology

- mandatory stack
- external integrations
- libraries

---

## 4. Input Contracts

**Scope:** validation and format **in the input limit** (parse, type, mandatory, limits per field).

For each input:

- name
- type
- format (JSON, string, etc.)
- origin (user, API, system)
- mandatory validations **per field or payload**

**Do not** duplicate the global table of business errors or HTTP codes here — this is in section **6** (transversal / operation).

Example:

```json
{
  "address": "string",
  "zipcode": "string (8 digits)"
}
```


---

## 5. Output Contracts

**Scope:** what the system **returns** or **emits** (synchronous response, event, technical UI binding).

For each output:

- name / channel (API response, event, queue)
- type and format
- semantics (client-readable success vs failure)
- observable side effects when applicable

It must be **consistent** with inputs and flows; **does not** contradict section **4** or **6**.

---

## 6. States, errors and codes

**Scope:** **transversal** behavior after valid input — domain errors, conflicts, unavailability, HTTP/gRPC codes, state machine if any.

- Error contract (code, message, retry, idempotency)
- Resource states (draft, active, canceled, etc.) if applicable

**Difference from section 4:** section 4 covers **rejection of invalid input**; This section covers **failures and states during or after** valid processing.

---

## 7. Flows and sequences

- Main flow (step by step: actor → system → effects)
- Alternative flows and branches
- Competition or mandatory ordering (if applicable)

---

## 8. Data model (if applicable)

**Scope:** **structural** form of the persisted data or domain (schema, entities, relations).

For each entity or aggregate:

- name
- fields and types
- schema constraints (unique, mandatory, FK, checks) and relevant **indexes**
- relationship with inputs/outputs (cross-reference, without verbosely repeating the JSON contract if already defined in 4/5)

**Invariants in this section:** those that are expressed as a **data or integrity rule** (e.g.: single column, non-negative balance **in the model**).

---

## 9. Edge cases and operational guarantees

**Scope:** behavior under adverse or unusual conditions **at runtime** — does not replace section 4 input validation.

- Border entrances no longer covered in 4
- timeouts, reexecution, duplicity (queues, idempotency)
- empty or partial states
- **Operational guarantees:** what must remain true **in any flow** (including error, retry, concurrency) — e.g., consistency after duplicate event, limits under load

**Invariants in this section:** those that are **system behavior promises**, not just columns in the database (they may reference rules from §8, but describe **how** the code preserves them).

---

## Integration with `/plan` (CRITICAL)

- This specification should allow plan creation **without assumptions**
- If `/plan` needs to assume something → spec is incomplete

---

## Mandatory validation

Before finishing, answer:

- Full specification: YES / NO
- Ambiguities: (list)
- Conflict with `.agents`: YES / NO
- Conflict with `docs`: YES / NO

---

## Blocking rules

- If PRD is incomplete → STOP
- If there is ambiguity → STOP
- If technical information necessary to implement is missing → STOP
- If there is a conflict with `.agents` → STOP
- If there is an unresolved technical trade-off and the user has not yet chosen an option or decision criteria (see *Technical ambiguity, trade-offs and user choice*) → STOP

---

## Important

- DO NOT implement
- DO NOT generate code
- DO NOT assume behavior not derivable from PRD + explicit decisions in this spec
- This command defines technical basis for the plan

---

## Mandatory output format

## Status

- Specification created / Locked

---

## Analysis

### Save preference

- User decision: Save / Don't save
- When to save: Defined documentation destination

---

### Solution structure

- technical overview

---

### Specification Clarity

- complete / incomplete

---

### Ready for planning

- YES / NO

---

## Problems

- ambiguities
- gaps
- inconsistencies

If there is none:
→ None

---

## Next steps

If complete:

- Go to `/plan`

If incomplete:

- Adjust specification
- Request information
