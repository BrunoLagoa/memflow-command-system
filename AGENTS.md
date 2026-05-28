# AGENTS Notes

## What this repo is
- This repo ships slash-command definitions for OpenCode; the actual install payload is `src/` (installer copies `src/*` into `.../commands/memflow`).
- If you change command behavior, edit files in `src/` (especially `src/_shared/*` and command `.md` files), not generated install locations under `~/.config/...` or `.opencode/...`.

## High-value layout
- `src/*.md`: executable command specs (`context`, `workflow`, `brainstorm`, `execute`, `review`, etc.).
- `src/_shared/*.md`: shared normative bases referenced by command specs.
- `scripts/install.sh` and `scripts/install.ps1`: canonical installer/update/check/uninstall logic.
- `scripts/memflowctl` and `scripts/memflowctl.ps1`: thin wrappers that download and run installer scripts from GitHub (`main` by default).
- `.github/workflows/install-regression.yml`: runs installer regression shell/PowerShell tests.
- `.github/workflows/commit-convention.yml`: validates Conventional Commits format on PRs/pushes to `main`.

## Commands you should actually run
- Installer regression suite: `scripts/tests/test-install-regression.sh`
- Same as CI (from repo root): `chmod +x scripts/tests/test-install-regression.sh && scripts/tests/test-install-regression.sh`
- Command behavioral contracts: `scripts/tests/test-command-contracts.sh`
- Commit convention check: `bash scripts/tests/test-conventional-commits.sh`
- Show installer help quickly: `bash scripts/install.sh --help` and `pwsh ./scripts/install.ps1 -?`

## Behavior quirks that are easy to miss
- `/workflow` may route to `/brainstorm` before `/plan`, `/spec`, or `/prd` when clarity is low or trade-offs are unresolved; `/brainstorm` handoff is explicit (`Pronto para /prd`, `/spec`, or `/plan`).
- `/memory-save` requires explicit user confirmation before writing; score < 21 → do not save; reinforcement merges into existing decision (+5 score, version bump) instead of duplicating; `session-memory.md` holds 500–1000 tokens during session (not a log), cleared after successful save; insights/suggestions evict by explicit retention criteria; suggestions archived after 3 consecutive ignores; when in doubt → do not save.
- `/memory-init` bootstrap creates five memory files including `decision-suggestions.md`.
- `update`, `check`, and `uninstall` without explicit scope auto-discover manifests and operate on all detected installs (global and/or local), in order `global -> local`.
- Missing installation for `update`/`uninstall` returns exit code `2` in non-interactive mode (covered by regression tests).
- For local scope outside current project directory, callers must pass project dir explicitly (`--project-dir` / `-ProjectDir`) or installer blocks.
- `check` is intentionally quiet when nothing is installed or no update is available.
- `--version local` in installers means "install from local repo `src/`" (used heavily by tests).

## Conventions in command specs (`src/*.md`)
- Keep frontmatter keys (`name`, `description`, `metadata.version`, etc.) intact; these files are consumed as command definitions.
- Shared files in `src/_shared` and `src/model-policy.md` are non-executable references (`hidden: true` where present); commands reference them by absolute path semantics in content.
- Content language is Portuguese (pt-BR) and command output rules in `src/_shared/base-output.md` require pt-BR responses; preserve this unless intentionally changing product behavior.

## Documentation sync rules
- If installer behavior changes, update `README.md` and `CHANGELOG.md` in the same change.
- If command behavior changes, update `CHANGELOG.md` and sync public docs as applicable (`README.md`, `README.pt-BR.md`, `docs/SDLC*.md`, and `src/model-policy.md` when model tiers or SDLC flow change).
- If adding/removing manifest fields, keep `scripts/manifest.schema.json` aligned.
