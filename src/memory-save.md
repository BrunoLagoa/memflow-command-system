---
name: memory-save
description: Saves session state and relevant decisions — with automatic detection, scoring, versioning, decision dashboard, metrics, insights, suggestions, and growth control. Integrates results from /review and /review-code into the quality cycle. Output: Status (Saved/Blocked/Not required), Analysis, Problems, and Next steps.
license: MIT
metadata:
  author: BrunoCastro
  version: "11.2.0"
---

## Common normative reference

Mandatory application:

- `_shared/base-output.md`
- `_shared/base-preconditions.md`
- `_shared/base-degraded-mode.md`
- `_shared/target-adapter.md`
- `model-policy.md`

---

## System integration (CRITICAL)

This command:

- MUST be used when `/execute` recommends (score ≥ 51) or after `/review` / `/review-code`
- CAN be manually invoked by the user at any time
- DOES NOT decide execution strategy (this is `/workflow`)
- DOES NOT implement code
- DO NOT overwrite decisions in `decisions.md` without explicit confirmation

Managed files:

- `.agents/memory/decisions.md`
- `.agents/memory/session-memory.md`
- `.agents/memory/quality-metrics.md`
- `.agents/memory/decision-suggestions.md`

---

## Objective

Save the current session state and preserve important decisions **without polluting memory**.

Manage `.agents/memory/decisions.md` as a **structured dashboard** — source of truth for persistent decisions with traceable history.

Ensure that:

- relevant decisions survive between sessions
- scores reflect actual use (reinforcement and obsolescence)
- quality metrics feed `/context` and `/workflow` in the next session
- `session-memory.md` acts as temporary session state (not log) and is cleared after successful persistence

---

## Step 0 — Preconditions (MANDATORY)

To check:

1. `.agents/memory/` exists
   - If NO → block and steer `/memory-init`
2. `.agents/memory/decisions.md` exists
   - If `.agents/memory/` exists but `decisions.md` DOES NOT → create base structure (same schema as `/memory-init`) and register in the analysis as a fallback
   - Prefer full `/memory-init` when memory has never been initialized
3. Valid anti-compaction invariants (pt-BR + Memflow)
   - If NO → block and steer `/context`
4. There is eligible content to save (relevant decision, metric, or session)
- If NO → status `Not required` and stop

---

## Step 1 — Validation of relevance (MANDATORY)

Run only if there is relevant content detected in:

- output of `/execute` (relevance score)
- output from `/review` or `/review-code`
- `session-memory.md` (temporary session state)
- saved artifacts (`.agents/docs/plans/`, `.agents/docs/brainstorm/`, etc.)

### DO NOT save if:

- technical logs or debug output
- trivial executions (score < 21)
- repetitions of information already present in `decisions.md`
- temporary content with no future impact
- actions without continuity between sessions
- session without execution, review or detectable decision
- user chooses "Do not save" at confirmation gate

### SAVE only if there is:

- important decisions
- relevant changes
- technical or architectural definitions
- useful context for future continuity
- eligible metrics after `/review` or `/review-code`

### Blocking rule

If there is NO relevant information:

- DO NOT update files
- status `Not required` (not to be confused with `Blocked`)
- if in doubt about relevance → **DO NOT save**

---

## Step 2 — Auto-detection of decisions

Analyze the current session and automatically identify decisions.

### Decision indicators

Detect patterns such as:

- "we decided that…"
- "we decided…"
- "let's use…"
- "We won't use it anymore…"
- "don't use it anymore…"
- "from now on…"
- "standardize…"
- "defined that…"
- explicit decisions in `/brainstorm`, `/plan`, `/spec` or `/prd` saved
- reinforcement of existing decision (same topic, additional evidence)

For each candidate, extract:

- **title/slug** (kebab-case, single)
- **decision text** (1–3 objective sentences)
- **context** (why it was taken)
- **category** (Criticism | Technique | UI/UX | Other)

---

## Step 3 — Relevance Score (0–100)

Aligned to `/execute`:

| Criterion | Points |
|----------|--------|
| Stack change | +40 |
| Architectural decision | +30 |
| Global standard | +20 |
| Impact multiple files | +10 |
| Local move | +5 |
| Trivial adjustment | 0 |

### Calculation rules

- add **only** criteria applicable to the session
- maximum limit: **100**
- **do not** duplicate equivalent criteria (e.g.: architecture + stack when one already covers the other)
- ensure that every saved decision has a coherent **Score** and **Impact** (impact is semantic, not mechanically derived from the score)

### Interpretation

- **0–20** → Do not save
- **21–50** → Can save (confirm with user)
- **51–80** → Recommend save
- **81–100** → Strongly recommend

---

## Step 4 — Impact Determination

Rate each decision:

- **Low** — local scope, reversible, without systemic effect
- **Medium** — affects relevant module or flow
- **High** — architecture, security, public contract, or multiple domains

---

## Step 5 — Category Classification

Map to section in `decisions.md`:

| Type | Section | Examples |
|------|-------|----------|
| Security, compliance, invariants | `## Critical` | stack, architecture, structural changes |
| Standards, technical rules, implementation | `## Technical` | code standards, libraries, internal contracts |
| Design, UX, accessibility | `## UI/UX` | interface, experience, navigation |
| Other | `## Other` | fallback when it doesn't fit above |

Also record in `## Recent` (maximum 5 entries — see Step 9).

Keep `decisions.md` organized by category — don't mix types.

---

## Step 6 — Structure of `decisions.md`

If `.agents/memory/decisions.md` does not exist (fallback from Step 0), create:


```md
# Project Decisions

## Critical
## Technical
## UI/UX
## Other
## Recent
## History
```


### Mandatory scheme by decision


```md
### {slug} (score: N)
- Category: Critical | Technical | UI/UX | Other
- Impact: Low | Medium | High
- Decision: <objective text>
- Context: <why it was taken>
- Date: YYYY-MM-DD
- Version: 1
```


### Slug rules

- kebab-case (`dark-mode-strategy`, `email-normalization`)
- unique in the file
- stable between sessions (don't rename for no reason)

---

## Step 7 — Versioning and score lifecycle

Before writing, compare each candidate with existing `decisions.md`.

### New decision

- create entry with score calculated in Step 3
- `Version: 1`

### Reinforcement (same theme, additional evidence, or successful use)

- **do not** create duplicate
- update `Decision` and `Context` if there is new information
- score: **+5** (maximum 100)
- increment `Version`

### Contradiction (previous decision violated or reversed)

- add note in `Context` with date and reason
- score: **−15** (minimum 0)
- if score < 30 → move to section `## History` with obsolescence note

### Exact duplicate

- merge into existing entry
- **do not** create new

---

## Step 8 — Mandatory confirmation before writing (CRITICAL)

Before changing any file, present a summary and request confirmation:


```
Summary of what will be saved:

Decisions:
- {slug} (score: N, {new|reinforcement|update})
- ...

Metrics: {yes|no}
Session-memory: will be cleared after saving

Do you want to persist?

A) Yes, save all
B) Save decisions only (no metrics)
C) Do not save
```


- **A** → proceed with Steps 9–13
- **B** → skip Step 11 (metrics), continue
- **C** → status `Not required` and stop

DO NOT write files without explicit confirmation.

---

## Step 9 — Writing of and recent decisions

1. Insert or update entries in the correct sections (`Critical`, `Technical`, `UI/UX`, `Other`)
2. Update `## Recent`:
   - add slug + date at top
   - keep **maximum 5** entries
   - remove the oldest if it exceeds

---

## Step 10 — `session-memory.md` (during and after the session)

### During the session (before saving)

- `session-memory.md` is **temporary state** — not log, not `decisions.md`
- DO NOT turn into permanent history
- keep between **500–1000 tokens** when there is active content
- if you exceed 1000 tokens before saving → condense (remove redundancies), **do not** truncate decisions already detected
- record only operational context of the current session

### After successful persistence

- clear temporary operational contents of `session-memory.md`
- keep minimal placeholder or empty file
- register in analysis: `Session-memory cleared: YES`

If persistence fails or user cancels → **don't** clean up.

---

## Step 11 — Logging Metrics

### Conditions

Register ONLY if:

- there was `/review` or `/review-code` in this session
- execution was not trivial

### Data collected

- `review_result`: approved | approved_with_reserves | failed
- `review_code_result`: approved | approved_with_reserves | failed
- `rework`: yes | no
- `complexity`: low | average | high

### `quality-metrics.md` Update

If the file exists in the legacy format (for example, a loose `approval_rate:` entry), migrate it to the structure below before incrementing counters.

Increment counters and recalculate KPIs:


```md
# Quality Metrics

## Executions

- total: N
- approved: N
- approved_with_reservations: N
- failed: N

## KPIs

- approval_rate: N%
- failure_rate: N%
- average_rework: N

## Current snapshot

- Executions: N
- Approval rate: N%
- Failure rate: N%
- Average rework: N
- Main risk: <short text>
- Trend: improving | stable | getting worse

## Observations

- (insights generated in Step 12)
```


### Effect on next session

- `/context` classifies quality (high | average | low)
- `/workflow` may require `/plan` or enhanced validation when quality is low

---

## Step 12 — Generating Insights

Analyze patterns in recent metrics and observations.

### Conditions

Generate insight ONLY if:

- total runs ≥ 3
- consistent pattern (≥ 2 similar occurrences)

### Types of insight

- `high_risk_due_to_clarity` — tasks with low clarity fail more often
- `high_risk_due_to_integration` — external integrations fail frequently
- `need_for_planning` — direct runs fail frequently
- `need_for_stronger_validation` — recurring failures in specific areas

### Insight Control (CRITICAL)

- maximum **10** active insights in `quality-metrics.md` (section `## Observations`)
- if exceeded → apply eviction in the order below (remove the first eligible):

### Eviction criteria (insights)

**Retention** priority (keep the best scorers):

1. **Recency** — occurrence in the last 5 sessions recorded in `## Executions`
2. **Impact on KPI** — insight linked to recent rejection or rework
3. **Frequency** — pattern with ≥ 3 occurrences in history
4. **Date** — most recent prevails in a tie

Remove the insight with the **lowest** score first in that order. Record in the analysis which insights were removed.

### Insight format in `## Observations`


```md
- [{type}] {short description} (occurrences: N, last: YYYY-MM-DD)
```


Example:


```md
- [high_risk_due_to_integration] external integrations fail frequently (occurrences: 4, last: 2026-05-28)
```


---

## Step 13 — Suggested decisions

Transform recurring patterns into **structured suggestions**, without automating.

### Conditions

Run ONLY if:

- total_executions ≥ 5
- there is relevant insight from Step 12
- consistent pattern identified

### Structure in `decision-suggestions.md`


```md
## Suggestion: {title}

Reason:
<metrics-based explanation>

Recommendation:
<suggested action>

Expected impact: low | medium | high
Confidence: low | average | high
Consecutive ignores: 0
Status: active
Date: YYYY-MM-DD
```


### Suggestion control (CRITICAL)

- maximum of **5** suggestions with `Status: active`
- if exceeded → apply eviction (see criteria below)

### Eviction criteria (suggestions)

**Retention** priority (keep the ones that score the best):

1. **Confidence** — high > medium > low
2. **Expected impact** — high > medium > low
3. **Recency** — most recent `Date`
4. **Less ignored** — lower `Consecutive ignores`

Remove the suggestion with the **lowest** score first in that order. Register in analysis.

### Expiration of ignored suggestions

- when the user **ignores** via `/workflow` → increment `Consecutive ignores` by +1
- when the user **applies** it → remove suggestion from active list
- if `Consecutive ignores` ≥ **3** → archive:
  - change `Status: archived`
  - move to section `## Archived` at the end of `decision-suggestions.md`
  - DO NOT resubmit in `/workflow` unless regeneration with new insight

### Suggestion deduplication

- DO NOT allow suggestions with the same title
- if already exists → update existing, DO NOT create new

### Integration with `/workflow`

- suggestions are **assisted mode** — never applied automatically
- user decides to apply or ignore via `/workflow`
- apply → convert into decision and register via `/memory-save`

---

## Model usage (ALIGNED TO MODEL-POLICY)

- Decision detection and classification → economic model
- Generation of insights and suggestions → intermediate model when history ≥ 5 executions
- Escalate only if high ambiguity in classification

---

## Mandatory rules

1. DO NOT save without explicit confirmation
2. DO NOT duplicate decisions (merge or reinforce)
3. DO NOT pollute memory with trivial adjustments (score < 21)
4. DO NOT clear `session-memory.md` if persistence failed
5. DO NOT turn `session-memory.md` into permanent log
6. DO NOT automatically apply suggestions
7. DO NOT decide execution strategy
8. If in doubt about relevance or conflict → **DO NOT save**

---

## Good practices

- use at the end of each relevant task (especially after `/review`)
- avoid use in trivial tasks
- prioritize quality over quantity of inputs
- `.agents/memory/decisions.md` is the source of truth — score should reflect real importance

---

## Mandatory output format

## Status

- Saved
- Blocked
- Not necessary
- Partial

---

## Analysis

### Validation

- Relevant content identified: YES / NO
- Decisions detected: YES / NO
- Calculated score: X/100
- Impact: Low | Average | High
- Category assigned: Critical | Technical | UI/UX | Other
- Type of action: New decision | Reinforcement | Update | Metrics | Session
- Justification: (brief)

### Persistence

- Saved decisions: N (slug list)
- Reinforced Decisions: N
- Archived decisions: N
- Updated metrics: YES / NO / N/A
- Insights generated: N
- Suggestions generated: N
- Clear session-memory: YES/NO

### Session score

- Relevance score: X/100
- Original `/execute` recommendation: (if applicable)

### Changed files

- `.agents/memory/decisions.md`
- `.agents/memory/quality-metrics.md`
- `.agents/memory/decision-suggestions.md`
- `.agents/memory/session-memory.md`

---

## Problems

- Irrelevant information (if `Not required`)
- Ambiguities in classification or detection
- Possible conflict with existing decisions
- Limitations of automatic detection
- Missing or incomplete Bootstrap

If there is none:
→ None

---

## Next steps

If `Not required` or `Blocked`:

- No persistence action required

If `Saved`:

- `/context` — reload updated memory
- Decision dashboard updated in `decisions.md`
- Continue SDLC flow as per `/workflow`
- Review pending suggestions in `decision-suggestions.md` (if generated)
