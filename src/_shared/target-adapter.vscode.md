---
description: It is not an executable command. Target adapter for prompts generated in VSCode.
license: MIT
hidden: true
metadata:
  author: BrunoCastro
  version: "1.2.0"
---
# Target adapter (VSCode)

Apply this adapter when the active target is `vscode`.

## Normative resolution

- In prompts generated for VSCode, `_shared/*.md` normative bases should be treated as local content injected into the prompt itself.
- In prompts generated for VSCode, `model-policy.md` also comes as a block injected into the same prompt file (there is no separate `memflow.model-policy` prompt in the VS Code installation).
- Do not apply resolution via OpenCode global paths/locais.
- `model-policy.md` must be interpreted in the context of the prompt generated for VSCode (full text already present in the prompt when the injectable line was expanded by the installer).

## Lack of content

- If a required normative basis is not present in the generated prompt:
  - report absence
  - block critical execution

## Precedence

- This adapter sets the resolution to `vscode`.
- Commands can extend operational rules without removing requirements from this adapter.
- Non-overwriteable invariants:
  - `_shared/*.md` must be injected into the prompt
  - `model-policy.md` must be injected into the prompt (same mechanism as `_shared`)
  - lack of necessary normative basis blocks critical execution