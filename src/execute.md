---
name: execute
description: Implements code based on the /workflow decision respecting `model-policy.md` of the active target. Without explicit decision by /workflow, block and return to orchestration. Includes integration with smart persistence and quality metrics.
license: MIT
metadata:
  author: BrunoCastro
  version: "3.4.0"
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

Run the deployment:

- respecting the decision of `/workflow`
- following `model-policy.md`
- maintaining consistency with `.agents` and `docs`

This command does NOT decide strategy, it just executes it.

---

## Using MCP tools

### Serena MCP (PRIORITY)

- locate exact points of change
- edit code accurately
- avoid duplication
- understand dependencies

Prioritize:

- find_symbol
- find_referencing_symbols
- replace_symbol_body
- insert_before_symbol / insert_after_symbol

Avoid:

- edit entire files without need

---

## Decision validation (MANDATORY)

### Is there a decision from `/workflow`?

- YES → follow decision  
- NO → BLOCK and return to `/workflow`

---

## No decision from `/workflow`

- Status: Partial
- Reason: Missing strategy decision
- Mandatory action: execute `/workflow`
- DO NOT classify complexity/impact/risk within `/execute`

AND STOP.

---

## Gate anti-compaction (MANDATORY)

Before executing implementation, validate in the active context:

- pt-BR language confirmed
- Memflow identity confirmed

If either is missing or fails:

- Status: Partial
- Reason: invalid anti-compaction invariants
- Mandatory action: rerun `/context`
- DO NOT implement until revalidation

AND STOP.

---

## Integration with `/workflow`

- RUN DIRECT → run  
- PLAN → block  

---

## Explicit premises (MANDATORY)

Before changing code:

- list adopted execution assumptions
- list open ambiguities
- if there is more than one valid interpretation for the same task:
  - STOP
  - request explicit decision from the user
- DO NOT hide uncertainty or choose interpretation silently

---

## Simplicity first

- implement the minimum necessary to resolve the request
- DO NOT add unsolicited features, flexibility or abstractions
- DO NOT create treatment for impossible scenarios in the current context
- if there is a simpler option with the same result, prioritize the simpler option

---

## Template usage- follow model-policy  
- execution → economic model  
- climb only if necessary  

---

## Climbing

1st failure → fix  
2nd failure → review approach  
3rd failure → scale model  

---

## Execution

- implement code  
- adjust files  
- follow project standards  

---

## Integration with saved plan (Vivo Plan)

When there is a plan saved in `.md`:

- read the saved plan before starting implementation
- map planned tasks/subtasks to current execution
- respect the execution method defined in the plan:
  - `[P]` parallelizable: can run in parallel with other `[P]` when there is no conflict
  - `[S]` sequential: execute in the planned order
- update the progress checklist on the saved plan during execution using the default legend:
  - `[ ]` pending
  - `[-]` in progress
  - `[x]` completed
  - `[!]` blocked
- preserve `[P]` and `[S]` mode markers during status updates
- maintain consistency between parent task and subtasks when updating status:
  - only mark parent task as `[x]` when all subtasks are `[x]`
  - when there is subtask `[-]`, reflect parent task as `[-]`
  - when there is a subtask `[!]`, do not mark the parent task as `[x]`
- update in top-down order (parent task -> subtask) to avoid contradictory state
- when there is item `[!]`, register in the saved plan:
  - objective reason for blocking
  - action required to unlock
  - expected person responsible for the action (user, agent or external system)
  - exit criteria to return to `[ ]` or `[-]`
- update the last checkpoint and the next step at the end of the execution
- if the execution stops in the middle, clearly record where it stopped and what remains to resume

If there is no saved plan:

- execute normally based on `/workflow` decision

---

## Security

- respect `.agents`  
- avoid exposing secrets  
- separate client/server correctly  

If `.agents` missing:
- apply good practices  
- degraded mode  

---

## Tests

- detect runtime  
- run relevant tests  
- avoid regression  

---

## Stack detection

Identify:- language/runtime  
- manager  
- lint/test commands  

---

## Mandatory quality

After implementing:

1. setup (if necessary)  
2.format  
3. lint/typecheck  
4. testing  

If an error occurs, fix it and repeat the cycle until the success criteria defined in the plan/scope are validated.

---

## Goal-oriented execution (MANDATORY)

For each step implemented:

- define verifiable objective
- perform objective validation (test, command, evidence of behavior)
- only move forward when validation passes

Recommended format:

1. `<step>` → check: `<command/test/evidence>`

---

## Specific rules

- DO NOT overwrite without analysis  
- DO NOT duplicate code  
- DO NOT change multiple files unnecessarily  
- apply surgical changes: each changed line must have a direct link with the request
- DO NOT refactor adjacent parts outside the scope of the request
- remove only leftovers generated by the change itself (orphan imports/variable/funtions created by the change)
- DO NOT auto-execute next flow commands without user confirmation
- DO NOT end execution with an outdated saved plan when there has been progress in tasks/subtasks

---

## Resilience

- simple error → fix  
- structural error → review plan  
- recurring error → escalate  

---

# Intelligent persistence (AUTO MEMORY)

After execution, evaluate memory relevance.

---

## Relevance assessment

Check if there was:

- technical decisions  
- relevant changes  
- defined standards  
- architectural choices  
- useful context  

---

## Decision detection

Detect patterns:

- “let’s use…”  
- “we decided…”  
- “standardize…”  
- “don’t use it anymore…”  
- “from now on…”  

---

## Relevance score (0–100)

- Stack change: +40  
- Architectural decision: +30  
- Global standard: +20  
- Impact multiple files: +10  
- Local change: +5  
- Trivial adjustment: 0  

---

## Interpretation

- 0–20 → Do not save  
- 21–50 → Can save  
- 51–80 → Recommend  
- 81–100 → Strongly recommend  

---

## Result

If score ≥ 51:

→ Run `/memory-save`

If score < 51:

→ No need to save  

---

# Integration with quality metrics (NEW)

If execution is followed by:

- `/review`
- `/review-code`

So:

→ Prioritize execution of `/memory-save`

Objective:

- record quality of execution  
- feed system history  
- allow future analysis  

---

## Important

- DO NOT decide strategy  
- DO NOT skip validations  
- DO NOT end with an error  
- DO NOT execute without understanding  

---

# Mandatory output format

## Status

- Executed / Failed / Partial  

---

## Analysis

- What was done  
- Changed files  
- Explicit premises and ambiguities addressed
- Traceability: changes linked to the order (YES / NO)
- Use of Serena  
- Use of fallback  
- Adherence to the workflow  
- Mode: Normal / Degraded  
- Updated saved plan: YES / NO / N/A
- Registered resumption checkpoint: YES / NO / N/A

---

## Problems

- Errors or risks  
- Impacts  

If there is none:
→ None  

---

## Suggested persistence

- Relevance score: X/100  
- Relevant content: YES / NO  
- Decisions detected: YES / NO  
- Eligible quality metrics: YES / NO  
- Recommendation:
  - Run `/memory-save`
  - No need to save  

---

## Locks

- Plan required → STOP  
- Conflict with `.agents` → STOP  
- Lack of context → STOP  
- Failure of anti-compaction invariants → STOP

---

## Next steps

- `/review`  
- `/review-code` (if applicable)  
- `/memory-save` (recommended after validation)  
- `/review-enforce-rules` (optional)  
- `/test-plan` (if applicable)  
- Wait for explicit confirmation from the user before executing any next command