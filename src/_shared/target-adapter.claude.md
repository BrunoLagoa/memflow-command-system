---
description: It is not an executable command. Target adapter for commands generated in Claude Code.
license: MIT
hidden: true
metadata:
  author: BrunoCastro
  version: "1.0.0"
---
# Target adapter (Claude Code)

Apply this adapter when the active target is `claude`.

## Normative resolution

- In commands generated for Claude Code, `_shared/*.md` normative bases should be treated as local content injected into the command file itself.
- In commands generated for Claude Code, `model-policy.md` also comes as a block injected into the same command file (there is no separate `model-policy` command in the Claude Code installation).
- Do not apply resolution via OpenCode global/local paths.
- `model-policy.md` must be interpreted in the context of the generated command (full text already present in the file when the injectable line was expanded by the installer).

## Installation layout

- Commands are installed locally per project at `<project>/.claude/commands/memflow/<command>.md`.
- Each file is a project slash command; the file name is the command name (e.g. `context.md` is invoked as `/context`).
- The `memflow` subdirectory is shown as the `(project:memflow)` namespace in `/help` and does not change the command name.
- There is no global/local split: the installation is always local to the project.

## Lack of content

- If a required normative basis is not present in the generated command:
  - report absence
  - block critical execution

## Precedence

- This adapter sets the resolution to `claude`.
- Commands can extend operational rules without removing requirements from this adapter.
- Non-overwriteable invariants:
  - `_shared/*.md` must be injected into the command
  - `model-policy.md` must be injected into the command (same mechanism as `_shared`)
  - lack of necessary normative basis blocks critical execution
