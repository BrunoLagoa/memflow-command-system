# AGENTS Notes

## What this repo is
- This repo ships slash-command definitions for OpenCode; the actual install payload is `src/` (installer copies `src/*` into `.../commands/memflow`).
- If you change command behavior, edit files in `src/` (especially `src/_shared/*` and command `.md` files), not generated install locations under `~/.config/...` or `.opencode/...`.

## High-value layout
- `src/*.md`: executable command specs (`context`, `workflow`, `execute`, `review`, etc.).
- `src/_shared/*.md`: shared normative bases referenced by command specs.
- `scripts/install.sh` and `scripts/install.ps1`: canonical installer/update/check/uninstall logic.
- `scripts/memflowctl` and `scripts/memflowctl.ps1`: thin wrappers that download and run installer scripts from GitHub (`main` by default).
- `.github/workflows/install-regression.yml`: only CI workflow; runs installer regression shell tests.

## Commands you should actually run
- Installer regression suite: `scripts/tests/test-install-regression.sh`
- Same as CI (from repo root): `chmod +x scripts/tests/test-install-regression.sh && scripts/tests/test-install-regression.sh`
- Show installer help quickly: `bash scripts/install.sh --help` and `pwsh ./scripts/install.ps1 -?`

## Behavior quirks that are easy to miss
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
- If adding/removing manifest fields, keep `scripts/manifest.schema.json` aligned.
