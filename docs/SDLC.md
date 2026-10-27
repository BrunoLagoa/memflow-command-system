# SDLC Complete - Software Development Life Cycle

<!-- README-I18N:START -->

**English** | [Português (Brasil)](./SDLC.pt-BR.md)

<!-- README-I18N:END -->

This document explains what SDLC (Software Development Life Cycle) is and how it applies to the AI-driven development system.

---

# What is SDLC

**SDLC (Software Development Life Cycle)** is the complete software creation process.

In Portuguese: **Ciclo de Vida do Desenvolvimento de Software**

---

# Complete SDLC

A complete SDLC covers every stage from start to continuous evolution:

```text
idea -> definition -> planning -> development -> testing -> validation -> delivery -> evolution
```

---

# SDLC Stages

## 0. Exploration (optional)

* Compare approaches before locking direction
* Effort too large for one session: map mode (`.agents/docs/maps/`)
* Technical and product trade-offs
* Validate assumptions against existing code
* Questions in rounds over the decision frontier, each with a recommended answer
* Domain language: glossary and ADRs in `.agents/domain/` (with confirmation)

In this system:

```
/brainstorm
```

When to use: insufficient clarity, multiple plausible approaches, or unresolved trade-offs.

Typical handoff: `/brainstorm` -> `/prd`, `/spec`, or `/plan` (per gate decision).

---

## 1. Discovery / Idea

* Problem definition
* Context understanding

In this system:

```
/prd
```

---

## 2. Specification

* Expected behavior definition
* Rules and flows
* Test seams, testing decisions, and out of scope
* Synthesis mode: from an approved `/brainstorm`, without a new interview

In this system:

```
/spec
```

---

## 3. Planning

* Implementation strategy
* Vertical-slice tasks with explicit dependencies (`Bloqueado por`)

In this system:

```
/plan
```

---

## 4. Development

* Code implementation
* Next task picked from the plan frontier; optional TDD (red -> green) at agreed seams
* Bugs: `/debug` builds a feedback loop first; the fix starts with a regression test

In this system:

```
/execute
```

---

## 5. Testing

* Functional validation
* Scenario coverage

In this system:

```
/test-plan
```

---

## 6. Validation

* Adherence verification
* Technical and architectural quality
* Two-axis technical review (Standards and Spec) with `/review-code`

In this system:

```
/review
```

---

## 7. Quality Gate

* Additional strict validation recommended before considering work done

In this system:

```
/review-enforce-rules
```

---

## 8. Maintenance and Evolution

* Bug fixing
* Refactoring
* Continuous learning

In this system:

```
/debug
/refactor
/memory-save
/memory-init
/retro
```

`/retro` improves the agent environment (checks, standards, steering files) based on what happened in the session.

At any stage, `/workflow` defines whether the task runs **with or without subagents** (default: without).

---

# SDLC in the AI system

The system implements a complete SDLC with commands:

```text
/context
/workflow
/brainstorm
/prd
/spec
/plan
/execute
/test-plan
/review
/review-enforce-rules
/debug
/refactor
/memory-save
/memory-init
/retro
```

---

# Difference from the traditional model

## Common AI usage

* isolated code generation
* no validation
* no flow control

---

## System with complete SDLC

* structured flow
* controlled decisions
* consistent validation (with optional strict gate)
* consistent quality

---

# Benefits

* Higher predictability
* Error reduction
* Better code quality
* Less rework
* Continuous evolution

---

# Essence

> Complete SDLC means turning an idea into functional, validated, and evolvable software.

---

# Conclusion

This system does not just use AI to generate code.

It implements:

# A complete AI-based engineering system grounded in SDLC
