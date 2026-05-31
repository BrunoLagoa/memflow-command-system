---
name: prd
description: Transforms an idea or problem into a structured, measurable and ready-to-execute PRD. Includes strategic definition, user experience, technical requirements and validation criteria. System base — powers /spec → /plan → /execute. Does not implement. In case of ambiguity or trade-off, it can present options and even block the user's decision. Blocks if information is missing or there is unresolved ambiguity.
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

Transform an idea or problem into a PRD:

- Of course
- full
- measurable
- unambiguously
- ready to feed `/spec` and `/plan`
- usable as a single source of truth

---

## System integration

This command:

- is the basis of the system
- feeds `/spec` → `/plan` → `/execute`
- influences `/workflow` decisions
- defines system scope and limits

---

## Model usage (ALIGNED TO MODEL-POLICY)

This command should:

- use intermediate or higher model
- prioritize accuracy over speed
- avoid unvalidated inferences

---

## Expected input

The user must provide:

- idea/problem
- context
- desired goal

If incomplete:
→ request more information before continuing (MANDATORY)

---

## Mandatory phase: Discovery (BEFORE GENERATING PRD)

Before generating the PRD, validate:

- What real problem is being solved?
- Why is this important now?
- How will success be measured?
- Are there any technical or business restrictions?

If any answer is undefined:
→ BLOCK PRD generation

## Mandatory save confirmation (BEFORE any PRD generation)

Before starting the analysis and creation of the PRD, ASK the user:

- Do you want to save the PRD that will be created to maintain documented data?

It is mandatory to present clear options:

- Yes, save the PRD
- No, just show in chat

Rules:

- DO NOT start PRD generation before user response
- Ask the question in a structured dialogue with selectable options (not in free text)
- If the answer is ambiguous, ask again using the same options
- Maintain the same structured dialogue format in repetition attempts
- Record the chosen preference in the output (save or not save)
- If the user chooses to save, define and register the documentation destination before continuing

### Ambiguity, trade-offs and user choice

When there is **more than one valid interpretation**, **relevant trade-off** between alternatives or **scope conflict/comportamento** not yet decided by the user:

- **Don't** choose product direction, scope, or expected behavior on your own.
- Present **2 to 4 options** with brief pros and cons; may include **reasoned recommendation**, without replacing the user's decision.
- **BLOCK** the generation (or continuation) of the PRD until the user **chooses an option** or **defines explicit decision criteria**.

---

# PRD structure

---

## 1. Executive Summary

### Problem Statement
- Objective description of the problem (1–2 sentences)

### Proposed Solution
- Objective description of the solution (1–2 sentences)

### Success Criteria (mandatory KPIs)
- Measurable metrics
- Must contain numeric value + condition

Example:
- Response time < 200ms in 95% of cases
- Success rate ≥ 90%

---

## 2. Context

- Current scenario
- Impact of the problem
- Why settle this now

---

## 3. Objective

- Expected result
- Mandatory KPIs (not optional)

---

## 4. User and Experience

### Personas
- Who will be impacted
- Current pain

### User Stories (MANDATORY)
Format:
> As a [user], I want to [action] so that [benefit]

### Acceptance criteria per story (MANDATORY)

**Scope:** each User Story above.

- What needs to be true for **that story** to be ready (include reference to the story).
- Positive and negative cases **in the story outline** (behavior, data, permissions).
- **Do not** repeat the global delivery or increment validation here — this is in section **11** (PRD / release level).

---

## 5. Scope

### Includes
- Clear list of what will be done

### Non-Goals (MANDATORY)
- What will NOT be done at this stage
- Conscious exclusion decisions

---

## 6. Business rules

- Mandatory rules
- Restrictions
- Expected behaviors

---

## 7. AI Requirements (If applicable)

### Templates and tools
- LLMs used
- External APIs
- Auxiliary tools

### Fallback strategy
- What happens in failures

---

## 8. Assessment Strategy

- How to validate quality
- Benchmarks
- Accuracy metrics
- Mandatory tests

Example:
- ≥ 85% accuracy
- ≤ 5% inconsistency

---

## 9. Technical Specification

### Architecture (high level)
- Data flow
- Components

### Integrations
- APIs
- Database
- authentication

### Security
- data processing
- privacy

---

## 10. Functional flow

- Interaction step by step
- System behavior

---

## 11. Acceptance criteria (PRD / release level)

**Scope:** set of delivery, increment or objective of this PRD — does not replace the criteria **by history** in section 4.

- How to validate **complete** success (demo, go-live, release acceptance criteria).
- **Cross-sectional** positive and error cases (end-to-end flows, integrations, aggregated SLAs, expected regression).
- Must be **consistent** with the criteria per story (section 4); **not** contradict.

---

## 12. Risks and dependencies

- Undefined points
- External dependencies
- technical risks

---

## Integration with `/spec` (CRITICAL)

- This PRD should allow creation of `/spec` without guesswork
- If `/spec` needs to assume something → PRD is incomplete

---

## Mandatory validation

Before finishing, answer:

- PRD is complete: YES / NO
- There are open questions: (list)
- Conflict with `.agents`: YES / NO
- Conflict with `docs`: YES / NO

---

## Blocking rules

- If there is ambiguity → STOP
- If information is missing → STOP
- If KPIs are not defined → STOP
- If there are no Non-Goals → STOP
- If Discovery has not been carried out → STOP
- If there is an unresolved ambiguity/trade-off and the user has not yet chosen an option or decision criteria (see *Ambiguity, trade-offs and user choice*) → STOP

---

## Important

- DO NOT implement
- DO NOT generate code
- DO NOT assume behavior
- DO NOT invent requirements
- This command sets the base of the entire system

---

## Mandatory output format

## Status

- PRD created / Blocked

---

## Analysis

### Save preference

- User decision: Save / Don't save
- When to save: Defined documentation destination

---

### Clarity of the problem

- well-defined / partial / indefinite

---

### Quality of the PRD

- complete / incomplete

---

### Ready for specification

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

- Go to `/spec`

If incomplete:

- Adjust PRD
- Request more information