---
name: workflow
description: Central orchestrator — decides exploration, execution, validation and adapts behavior based on decisions, metrics, insights and assisted suggestions, with predictability and evolution control. It is the sole source of strategy decisions for /brainstorm, /execute and /plan.
license: MIT
metadata:
  author: BrunoCastro
  version: "9.8.0"
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

Decide:

- execution (/execute or /plan)
- validation (/review, /review-code)
- template
- intelligent adaptation based on history

---

## Decision basis

- decisions.md
- quality-metrics.md
- decision-suggestions.md
- skills available in the project (if they exist)
- model-policy

---

# 🆕 Decision Priority (CRITICAL)

Mandatory order:

1. **decisions.md (always prevails)**
2. **applicable skills (if any)**
3. **workflow rules**
4. **insights (slight adjustment)**
5. **decision-suggestions (assisted mode)**

---

## Rules

- explicit decisions can NEVER be overwritten  
- available and applicable skills CANNOT be ignored
- DO NOT assume implementation assumptions without making them explicit in the output
- insights only adjust behavior  
- suggestions NEVER run automatically  
- in case of conflict → respect the order above  
- `/workflow` is the only strategy decision origin (`/brainstorm`, `/execute` vs `/plan`)
- DO NOT proceed without anti-compaction invariants validated by `/context`
- when there is a pending decision in `## Next steps`, use structured dialogue with selectable options

---

## Pending decisions in `## Next steps` (MANDATORY)

When `/workflow` depends on a user choice to follow (e.g. define scope, prioritize phase, choose implementation direction):

- present options in a structured and selectable dialog
- avoid open typing requests when there are concrete options
- allow option `Other` when it makes sense to not limit the user
- if the user chooses `Other`, request details afterwards (free text only at this stage)
- if the answer is ambiguous, repeat the same structured dialogue until there is an explicit selection
- record in analysis/problems that there is a pending decision and what choice was made when answered

---

# Step 0 — Existing decisions

- check previous decisions  
- prioritize by score  
- detect conflicts  

---

# Step 0.5 — Metrics

If it exists:

- approval rate  
- failure rate  
- medium rework  

---

# Step 0.6 — Insights

- low clarity  
- high complexity  
- external integrations  
- high rework  

---

# Step 0.7 — Decision Suggestions

If it exists:

.agents/memory/decision-suggestions.md

---

## Analyze suggestions

For each suggestion:

- title  
- recommendation  
- impact  
- confidence  

---

## Activation criteria

- confidence ≥ average  
- impact ≥ medium  

---

## 🆕 Usage limit (CRITICAL)

- apply dynamic limit per run:
  - low complexity and low risk: maximum **2 suggestions**
  - medium complexity or medium risk: maximum **3 suggestions**
  - high complexity or high risk: maximum **4 suggestions**
- when there are more eligible suggestions than the limit, prioritize by:
  - greater impact
  - greater confidence

---

## Assisted mode

- DO NOT apply automatically  
- just suggest  

---

# Step 0.8 — Project Skills (MANDATORY)

If `/context` indicates skills available in the project:

- identify skills relevant to the current task
- record which skills should be used before continuing
- guide explicit use of applicable skills

If there is a clearly applicable skill:

- DO NOT proceed to direct execution without guiding the use of the skill

If applicability is ambiguous:

- request objective confirmation from the user before proceeding

---

# Step 0.9 — Anti-compaction invariant gate (MANDATORY)

Validate whether `/context` confirmed invariants:

- validated pt-BR language
- validated Memflow identity

If status comes as `Reidratados`:

- allow normal continuity
- record in the output that there was post-compaction recovery

If status comes as `Failed` or absent:

- BLOCK workflow decision
- require re-execution of `/context`

---

# 🆕 Suggestion Application (INLINE 🔥)

When a suggestion is presented:

### The user can decide:

- **apply**
- **ignore**

---

## If applicable:

- convert recommendation into decision  
- register in `decisions.md`  
- remove from suggestion list  
- register via `/memory-save`  

---

## If ignored:

- increment `Consecutive ignores` in the corresponding suggestion in `decision-suggestions.md`
- keep the suggestion active while `Consecutive ignores` < 3
- if `Consecutive ignores` >= 3, `/memory-save` archives it (Step 13) and stops showing it in `/workflow`

---

## Important

- application must be explicit  
- never automatic  
- must generate traceability  

---

## Result

Add to output:

## Relevant suggestions

- title: <name>
- recommendation: <text>
- available action:
  - apply
  - ignore  

---

# Step 1 — Task Classification

- Complexity: low / medium / high  
- Impact: low / medium / high  
- Risk: low / medium / high  
- Clarity: high / medium / low  

---

# Step 1.5 — Assumptions and ambiguities (MANDATORY)

Before deciding on strategy:

- list assumptions assumed for the classification
- list doubts that impact decision
- if there is a critical unanswered question:
  - BLOCK decision
  - open structured dialog of options with the user
- DO NOT choose interpretation silently when there are multiple plausible readings

---

# Step 2 — Execution decision

---

## DIRECT EXECUTION

- low complexity  
- low risk  
- high clarity  

---

## RUN WITH /plan

- medium/high complexity  
- medium/high risk  
- low clarity  

---

## Adjust by insights

- low clarity → FORCE /plan  
- high complexity → prioritize /plan  
- high rework → avoid direct execution  

---

## EXPLORE WITH /brainstorm

Use when:

- low or medium clarity **and** multiple plausible approaches
- technical or product trade-offs not yet resolved
- undefined scope before `/prd` or `/plan`
- user request exploration of alternatives

Rules:

- DO NOT jump to `/execute` when `/brainstorm` is necessary
- after `/brainstorm` approved, handoff according to gate decision:
  - `/prd` — lacks product definition or business scope
  - `/spec` — PRD exists, deterministic technical decision is lacking
  - `/plan` — scope and approach clear enough to plan
- return to `/workflow` after brainstorm handoff before continuing

---

## Adjustment by insights (brainstorm)- low clarity + multiple approaches → FORCE /brainstorm before /plan
- architectural trade-off not decided → FORCE /brainstorm
- high clarity + evident unique approach → skip /brainstorm

---

# Step 3 — Validation Strategy

---

## /review

- ALWAYS mandatory  

---

## /review-code

Mandatory when:

- modified code  
- risk ≥ medium  
- external integration  
- architectural change  
- suggestion indicate technical risk  

---

## Adjust by insights

- external integration → FORCE /review-code  
- high error history → reinforce validation  

---

# Step 4 — Quality Gate

---

## BLOCK

- review = Disapproved  
- review-code = Deprecated  

---

## ALLOW WITH PROVISIONS

- any “with reservations”  

---

## APPROVE

- both approved  

---

# Step 5 — Model Orchestration

- economic model by default  
- escalate when necessary  

---

# Step 6 — Consistency control

- DO NOT ignore decisions  
- DO NOT ignore metrics  
- DO NOT ignore insights  
- DO NOT ignore suggestions  
- DO NOT ignore applicable skills
- limit influence of suggestions  

---

# Integration

- /brainstorm
- /execute  
- /review  
- /review-code  
- /memory-save  

---

# Rules

- DO NOT implement  
- DO NOT allow bypass  
- DO NOT ignore risk  
- demand return to `/workflow` if decision is absent

---

# Important

- decisions are sovereign  
- insights adjust  
- suggestions guide  
- system must remain predictable  

---

# Output format

## Status

- Decision made  

---

## Analysis

### Classification

- Complexity:
- Impact:
- Risk:
- Clarity:

---

### Premises and ambiguities

- assumptions assumed:
- ambiguities detected:
- pending decision with user: YES / NO

---

### Metrics

- available: YES / NO  
- failure_rate:

---

### Insights

- detected signals:

---

### Suggestions

- list of relevant suggestions  
- available actions: apply / ignore  

---

### Skills

- available in the project: YES / NO
- skills applicable to the task:
- action: use skill now / not applicable (justify)

---

### Anti-compaction invariants

- pt-BR language: OK / Failed
- Memflow identity: OK / Failed
- re-hydration required: YES / NO

---

### Strategy

- Exploration: Required (/brainstorm) / Not required
- Execution: Direct / Planned  
- Validation:

---

## Problems

- ambiguities  
- risks  
- failure of anti-compaction invariants (if any)

If there is none:
→ None  

---

## Next steps

1. /brainstorm (when exploration required) or /execute or /plan
2./review  
3./review-code  
4./memory-save  
5. If there is an applicable skill: use the skill before continuing
6. If anti-compaction invariants fail: rerun `/context`
7. If there is a pending decision to continue: open the selectable options dialog before proceeding