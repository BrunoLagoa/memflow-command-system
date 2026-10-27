---
name: test-plan
description: Generates complete test plan from the agreed test seams, with main scenarios, edge cases, security and regression — automatically detects the stack executor (Vitest, Jest, Playwright, Pytest, RSpec) and includes concrete execution commands. Output: Status, Analysis with detected executor and real commands, Problems and Next steps. Incomplete without concrete execution list.
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
- `_shared/base-domain-model.md`
- `_shared/target-adapter.md`
- `model-policy.md`
- Resolve these references according to `_shared/target-adapter.md` (no fallback outside the active target).

---

## Objective

Create a complete test plan aligned with the project.

---

## Base

- `.agents` → technical rules
- `docs` → business rules
- **Test seams** and **Testing decisions** sections of `/spec` (when they exist)
- terms from `.agents/domain/GLOSSARY.md` in test names

---

## Test seams (MANDATORY)

- Start from the seams confirmed in `/spec`; if there is no spec, propose seams and **confirm with the user** before the plan.
- For each proposed seam: one line on what it catches and what it misses.
- Test behavior through the public interface; no test at an unconfirmed seam.

## Anti-patterns (avoid)

- **Implementation-coupled:** mocks internal collaborators, tests private methods or verifies through a side channel (e.g. querying the database instead of using the interface). Tell: it breaks on refactor without behavior change.
- **Tautological:** the assertion recomputes the expected value the same way the code does (`expect(add(a, b)).toBe(a + b)`); expected values must come from an independent source.
- **Horizontal slicing:** writing all tests before any implementation; prefer vertical slices (one test → one implementation → repeat).

---

## Produce:

## Main scenarios
- Main system flows

## Test Cases
- Detailed list

## Edge cases
- edge cases

## Security
- Security testing (if applicable)

## Regression
- What needs to be guaranteed

## Strategy
- How to test (manual, unitary, e2e)

## Stack and executor detection (MANDATORY)

Before defining commands, identify:

- Main runtime and project language
- Configured test runner(s) (Vitest, Jest, Playwright, Pytest, RSpec, etc.)
- Actual commands available in the repository (scripts/config/documentation)

## Test execution (after the plan)

Always include:

- **What tests to run**: relevant file paths, folders, suites or filters
- **Concrete commands** to run only what is necessary, according to the detected stack
- **Mapping** of each critical scenario to at least one test/filtro (or select “create test”)
- **Approval criteria per scenario**: objective evidence of success/falha expected

### If you use Vitest

- Examples:
  - `npx vitest run <caminho/do/arquivo.test.ts>`
  - project script (e.g. `npm run test -- <args>`)

### If NOT to use Vitest

- Explicitly warn
- Report real executor and equivalent commands with the same level of detail
- Possible examples:
  - Jest: `npx jest <caminho/ou/filtro>`
  - Playwright: `npx playwright test <caminho/ou/grep>`
  - Pytest: `pytest <caminho/ou-k>`
  - RSpec: `bundle exec rspec <caminho/ou-tag>`

---

## Important

- Prioritize critical scenarios
- If context is missing → NOTIFY
- Do not assume Node/npm when it is not the project stack
- Plan without **concrete execution list of detected executor** → **incomplete**; do not treat the step as closed until this is stated in the response
- apply validation loop: reproduce scenario, run test, confirm evidence and only then mark as validated

---

## Mandatory output format

ALWAYS respond with:

## Status

- Test plan created / Blocked

---

## Analysis

- Test seams (confirmed)
- Scenarios covered
- Testing strategy
- Executor(s) detected
- Concrete execution commands

---

## Problems

- Coverage gaps
- Lack of context
- If none: None

---

## Next steps

- Run listed tests
- Adjust plan (if necessary)