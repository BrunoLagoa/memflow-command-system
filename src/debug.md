---
name: debug
description: Structured bug diagnosis — classifies the error (Simple/Estrutural/Critic), lists causes by probability and chooses a single most likely cause with evidence. Does not correct. Integrated into the workflow and `model-policy.md` of the active target (via `_shared/target-adapter.md`). Output: Status, Analysis, Problems and Next steps. Next step: /execute, /refactor or /plan depending on classification.
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

Deeply analyze an error, bug or unexpected behavior:

- identify root cause
- prioritize hypotheses
- guide research
- prepare base for safe correction

---

## System integration

This command:

- DOES NOT perform corrections
- DOES NOT replace `/execute`
- DOES NOT decide flow

It prepares for:

→ `/execute` (fix)
→ `/refactor` (structural improvement)
→ `/plan` (when necessary)

---

## Model usage (ALIGNED TO MODEL-POLICY)

This command should:

- use intermediate or advanced model
- prioritize diagnostic quality

---

## Rules

1. Base analysis on:
   - `.agents`
   - `docs`
   - expected system behavior

2. DO NOT implement fixes

3. After hypotheses:
   - choose **a single most likely cause**

---

## Error classification

Classify the error as:

- **Simple**
  - isolated error
  - low impact

- **Structural**
  - involves architecture
  - multiple points

- **Critical**
  - security
  - data
  - system flow

---

## Important

- DO NOT fix yet
- DO NOT skip investigation
- DO NOT list multiple causes without prioritizing
- Always indicate the most likely cause

---

## Mandatory output format

## Status

- Preliminary diagnosis / Waiting for data / Ready for correction

---

## Analysis

### Problem

- Clear description of the error

---

### Expected behavior

- Based on docs or rules

---

### Error classification

- Simple / Structural / Critical

---

### Possible causes

- List ordered by probability

---

### Most likely cause

- Only ONE
- Justify with evidence
- Confidence level: low / medium / high
- What would confirm or refute

---

### Technical analysis

- Where is the problem:
  - files
  - flow
  - logic

---

### Impact

- What can break

---

### Research plan

- Steps to validate
- Start with the most likely cause

---

## Problems

- Insufficient data
- Uncertainties
- Risks of wrong correction

If there is none:
→ None

---

## Next steps- Request logs/repro (if needed)
- Validate main hypothesis
- After confirmation:
  → `/execute` (simple error)
  → `/refactor` (structural error)
  → `/plan` (complex error)