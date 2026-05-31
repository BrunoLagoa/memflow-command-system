---
name: plan
description: Creates a detailed implementation plan when /workflow decides PLAN FIRST, aligned with `model-policy.md` of the active target (via `_shared/target-adapter.md`) — sequence of steps, affected files, impact, risks, and success criteria. Do not write code. Output: Status (Plan created/Locked), Analysis with 9 subsections, Problems, and Next steps. Block on ambiguity. Next command: /execute.
license: MIT
metadata:
  author: BrunoCastro
  version: "1.2.0"
---

## Common normative reference

Mandatory application:

- `_shared/base-output.md`
- `_shared/base-preconditions.md`
- `_shared/base-degraded-mode.md`
- `_shared/target-adapter.md`
- `model-policy.md`
- Resolve these references according to `_shared/target-adapter.md` (no fallback outside the active target).

---

## Objective

Create an implementation plan:

- clear
- full
- unambiguously
- ready to run via `/execute`

---

## System integration (CRITICAL)

This command:

- SHOULD be used when `/workflow` decides → PLAN FIRST
- Should NOT be used outside of this context without validation

---

## Using MCP Tools

If available:

### Serena MCP (PRIORITY)

- validate real code structure
- identify exact implementation points
- find files and dependencies
- avoid duplication

Prioritize:

- find_symbol
- find_referencing_symbols
- search_for_pattern
- get_symbols_overview

Avoid:

- assume structure
- plan non-existent files

---

## Model usage (ALIGNED TO MODEL-POLICY)

This command should:

- use a smarter model (e.g. GPT-5.4)
- prioritize quality over cost

---

### Main rule

- Planning → stronger model
- Execution → most economical model

---

## Mandatory rules

1. Based on:
   - `.agents` (when available)
   - `docs`
   - `model-policy.md` resolved by active target (via `_shared/target-adapter.md`)
   - real structure (via Serena, if available)
   - resolve `model-policy.md` with the active target rules (via `_shared/target-adapter.md`)

2. DO NOT write code

3. DO NOT assume undefined behavior

4. If there is ambiguity → STOP

5. If there is conflict → STOP

---

## Validation before planning

Before generating the plan:

- Is the problem clear?
- Is the scope defined?
- Is there enough context?
- Are premises and dependencies explicit?
- Are there multiple interpretations of the request?

If not:
→ STOP and request clarification

---

## Explicit premises (MANDATORY)

Before assembling the steps:

- state assumed premises
- declare points still uncertain
- if there is uncertainty that changes approach:
  - TO STOP
  - request user decision via objective options
- DO NOT assume silent interpretation when there is more than one valid reading

---

## Mandatory save confirmation (BEFORE any planning)

Before starting analysis and creating the plan, ASK the user:

- Do you want to save the plan that will be created to maintain documented data?

It is mandatory to present clear options:

- Yes, save the plan
- No, just show in chat

Rules:

- DO NOT start planning before user response
- If the answer is ambiguous, ask again using the same options
- If there is already an explicit save preference in the current session, reuse this preference by default and only confirm when a change is requested
- Register the chosen preference in the plan (save or not save)
- If the user chooses to save, include it in the plan where the content will be documented
- If the user chooses to save, structure the document as a living plan with a progress checklist per task/subtask for updates during `/execute`

---

## Specific rules

- DO NOT plan based on guesswork
- DO NOT create files without validating the need
- DO NOT ignore existing standards
- MUST scale the number of tasks according to actual complexity and scope, without reusing a fixed quantity between plans
- MUST apply dynamic sizing for implementation steps:
  - low complexity: 3-5 tasks
  - medium complexity: 6-10 tasks
  - high complexity: 10+ tasks with mandatory subtasks

---

## Limitations

If Serena is NOT available:

- warn limitation
- plan based on available files

If `.agents` is NOT available:

- warn limitation
- keep plan in degraded mode
- not automatically block for this reason

---

## Locks

- Lack of context → STOP
- Ambiguity → STOP
- Conflict with `.agents` (when it exists) → STOP
- Unknown structure → STOP

---

## Important

- DO NOT implement
- DO NOT move forward without complete clarity
- DO NOT proceed to `/execute` without validation
- This command sets the execution quality

---

## Mandatory output format

## Status

- Plan created / Locked

---

## Analysis

### Understanding

- What needs to be done

---

### Save preference

- User decision: Save / Don't save
- When to save: Defined documentation destination

---

### Applicable rules

- Relevant `.agents` (or absence in degraded mode)
- security (if applicable)

---

### Strategy

- high-level approach
- alignment with existing architecture

---

### Implementation steps

- clear and executable sequence
- based on real structure (when possible)
- number of tasks defined by dynamic sizing (complexity + real scope), with no fixed quantity reused between plans
- for high complexity, include subtasks
- mandatory final granularity checklist: can each item be executed without ambiguity?
- each step must include objective verification in the format:
  - `Step -> verify: test/command/expected evidence`
- Classify each task as:
  - `[P]` parallelizable (can run in parallel)
  - `[S]` sequential (depends on order)

---

### Affected files

- files to create or change
- validate with Serena (if available)

---

### Impact

- affected areas
- dependencies involved

---

### Risks

- technical
- business
- side effects

---

### Success criteria

- verifiable (non-generic) criteria to validate after `/execute`
- map each criterion to command, test, evidence, or expected output

---

### Execution tracking (Living plan)

- mandatory when the preference is to save the plan
- include a checklist per task/subtask with status: pending / in progress / completed / blocked
- include last execution checkpoint and next objective step for resumption
- include an execution mode marker per task/subtask:
  - `[P]` parallelizable
  - `[S]` sequential
- use standard checklist template for consistency:
  - `[ ]` pending
  - `[-]` in progress
  - `[x]` completed
  - `[!]` blocked
- Mandatory criteria to mark `[P]`:
  - no dependency on output from another task
  - no predictable conflict of files/critical areas
  - no blocking by sensitive shared state
  - with isolatable merge and rollback
- if any criteria fail, classify as `[S]`
- apply status consistency between parent task and subtasks:
  - parent task can only be `[x]` when all subtasks are `[x]`
  - if there is a subtask `[-]`, the parent task must be `[-]`
  - if subtask `[!]` exists, the parent task cannot be `[x]`
  - keep update in top-down order (parent task -> subtask) to avoid divergence
- for `[!]` (blocked) items, it is mandatory to register:
  - objective reason for blocking
  - action required to unlock
  - expected person responsible for the action (user, agent or external system)
  - lock exit criteria to return to `[ ]` or `[-]`

Recommended base template:

```md
### Execution progress

- [P][ ] Task 1
  - [S][-] Subtask 1.1
  - [P][x] Subtask 1.2
- [S][!] Task 2 (blocking reason)
  - Unblocking action: <objective action>
  - Responsible party: <user | agent | external system>
  - Exit criteria: <condition to return to [ ] or [-]>

Last checkpoint: <objective summary of the last completed point>
Next step: <objective action for resumption>
```

---

### Out of scope

- what will NOT be done

---

### Confidence in the plan

- Low / Medium / High

---

### Operating mode

- Normal / Degraded
- Impact of the absence of `.agents` (when applicable)

---

## Problems

- ambiguities
- lack of context
- conflicts with `.agents` or `docs`
- Serena's limitations

If there is none:
→ None

---

## Main model and alternatives

- Recommended level: (free/economic/intermediate/advanced)
- Main model: (ex: GPT-5.4)
- Alternative models (2-3, same level):
  - alternative 1
  - alternative 2
  - alternative 3 (optional)
- When to use alternatives:
  - main model unavailability
  - quota/limit reached
  - unstable latency
- Justification:
  - complexity
  - impact
  - risk

---

## Next steps

- Wait for confirmation
- Adjust plan (if necessary)
- Go to `/execute`
- When there is a saved plan: keep the checklist and checkpoint updated during execution
