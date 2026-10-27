---
description: It is not an executable command. Target adapter for commands generated in Cursor.
license: MIT
hidden: true
metadata:
  author: BrunoCastro
  version: "1.0.0"
---

# Target adapter (Cursor)

Apply this adapter when the active target is `cursor`.

## Normative resolution

- In commands generated for Cursor, `_shared/*.md` normative bases should be treated as local content injected into the command file itself.
- In commands generated for Cursor, `model-policy.md` also comes as a block injected into the same command file (there is no separate `model-policy` command in the Cursor installation).
- Do not apply resolution via OpenCode global/local paths.
- `model-policy.md` must be interpreted in the context of the generated command (full text already present in the file when the injectable line was expanded by the installer).

## Installation layout

- Commands are installed locally per project at `<project>/.cursor/commands/memflow/<command>.md`.
- The frontmatter is removed by the installer; the command description appears as a quote at the top of the file.
- There is no global/local split: the installation is always local to the project.

## Lack of content

- If a required normative basis is not present in the generated command:
  - report absence
  - block critical execution

## Subagents

- Subagent tool on this target: **Task** (Cursor subagents).
- Multiple Task calls in the same message run in parallel; custom subagents may exist in `.cursor/agents/`.
- Fact-finding → read-only exploration subagent when available; implementation and review → general-purpose subagent.
- Availability, allowed uses and fallback follow `_shared/base-subagents.md`.
- If the tool is not available in the session → operate without subagents (sequential fallback) and warn.

## Precedence

- This adapter sets the resolution to `cursor`.
- Commands can extend operational rules without removing requirements from this adapter.
- Non-overwriteable invariants:
  - `_shared/*.md` must be injected into the command
  - `model-policy.md` must be injected into the command (same mechanism as `_shared`)
  - lack of necessary normative basis blocks critical execution
