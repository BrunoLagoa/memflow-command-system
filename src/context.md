---
name: context
description: First command of the flow — loads memory (decisions, state and metrics), interprets patterns and prepares intelligent context for /workflow.
license: MIT
metadata:
  author: BrunoCastro
  version: "8.3.1"
---

## Command activation rule (CRITICAL)

When the user invokes `/context`, this command is already active.

- DO NOT only respond that normative references were registered
- DO NOT ask the user to run `/context` again
- DO NOT block because "preconditions are not validated yet"
- immediately execute the context, memory, metrics, skills and anti-compaction invariant loading described below

---

## Common normative reference

Mandatory application:

- `_shared/base-output.md`
- `_shared/base-preconditions.md`
- `_shared/base-degraded-mode.md`
- `_shared/target-adapter.md`
- `model-policy.md`

---

## Load context

---

# Persistent memory (HIGH PRIORITY)

If it exists:

- .agents/memory/memory.md
- .agents/memory/session-memory.md
- .agents/memory/decisions.md
- .agents/memory/quality-metrics.md

---

# Invariant rehydration (ANTI-COMPACTION)

Before completing `/context`, explicitly revalidate:

- mandatory system language: pt-BR
- project identity: Memflow Command System
- active scope: normative commands in `src/` and bases in `_shared`

If any item is missing from the active context:

- reload normative references
- record that there was post-compaction rehydration
- DO NOT mark context as complete without revalidating the 3 items

---

# Memory usage

## Primary Source (CRITICAL)

- memory.md → identity
- decisions.md → decisions

---

## Secondary source

- quality-metrics.md → performance

---

## Trust rule

If they exist:

- memory.md
- decisions.md

→ reliable memory

---

# Metrics interpretation

If it exists:

.agents/memory/quality-metrics.md

---

## Extract:

- approval_rate
- failure_rate
- observations

---

## Quality rating

- high_quality → error < 10%
- medium_quality → 10–30%
- low_quality → >30%

---

# Pattern interpretation (INSIGHTS)

If there are observations:

Example:

- "tasks with low clarity fail more"
- "external integrations have high error"

---

## Generate strategic signals

Convert observations to signals:

### Signal types:

- high_risk_for_clarity
- high_risk_for_integration
- planning_need
- need_for_reinforced_validation

---

## Internal result

Prepare structure:

- quality: high | medium | low
- signs:
  - list of detected signals

---

## Rules

- DO NOT decide action
- DO NOT modify flow
- DO NOT block execution
- just enrich context

---

# Optimized mode

If reliable memory:

---

## DON'T:

- scan project
- upload docs
- read code without need

---

## DO:

- load memory
- interpret metrics
- interpret signals
- use Serena optimized

---

# Fallback mode

If memory is missing:

- default behavior

---

# Main context

- .agents/**
- AGENTS.md
- project skills (if they exist)

---

# Project skills (MANDATORY when available)

Check existence of skills in the project (common examples):

- `.cursor/skills/**`
- `.cursor/skills-cursor/**`
- `.agents/skills/**`

If they exist:

- load inventory of available skills
- record names and summary purpose of each relevant skill
- signal to `/workflow` that there are potentially applicable skills

If they do not exist:

- record absence explicitly (without blocking)

---

# Context on demand

- docs
- code
- configs

---

# MCP integration

(maintained)

---

# Source priority

1. memory.md  
2. decisions.md  
3. quality-metrics.md  
4. .agents  
5. Serena  
6. docs  
7. code  

---

# Mandatory rules

- memory is primary source
- metrics are support
- signs do NOT replace rules
- avoid unnecessary reading
- DO NOT ignore skills available in the project
- include skill status in the context delivered to `/workflow`
- ALWAYS revalidate anti-compaction invariants (pt-BR + Memflow) before finalizing

---

# Output

---

## 🟢 Ultra-light

- Context: OK
- Memory: loaded
- Metrics: YES/NO
- Quality: high/medium/low
- Signals: none / detected
- Skills in the project: YES / NO
- Anti-compaction invariants: OK / Rehydrated

---

## Status

- Context: OK / Failed
- Memory: YES / NO
- Metrics: YES / NO
- Skills: YES / NO
- Anti-compaction invariants: OK / Rehydrated / Failed
- Mode: Normal / Degraded / Optimized

---

## Summary

- memory usage
- use of metrics
- detected signals
- available skills (if any)
- status of anti-compaction invariants (pt-BR + Memflow)

---

## Flow state

- Step: context

---

# Consistency rules

- DO NOT decide execution
- DO NOT apply metrics directly
- DO NOT apply signals directly
- DO NOT decide alone whether skill should be used
- ALWAYS delegate to /workflow

---

# Limitations

- observations may be incomplete
- signals depend on data quality
- absence of signs does not indicate absence of problem

---

# Important

- DO NOT implement
- DO NOT decide flow
- signals are strategic support

---

## Next steps

- Run /workflow