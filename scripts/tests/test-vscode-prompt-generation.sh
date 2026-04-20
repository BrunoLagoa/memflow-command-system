#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_SCRIPT="${SCRIPT_DIR}/../install.sh"

tmp_root="$(mktemp -d "${SCRIPT_DIR}/.tmp-vscode-generation.XXXXXX")"
cleanup() {
  rm -rf "$tmp_root"
}
trap cleanup EXIT

project_dir="${tmp_root}/project"
home_dir="${tmp_root}/home"
mkdir -p "$project_dir" "$home_dir"

env HOME="$home_dir" bash "$INSTALL_SCRIPT" install --target vscode --project-dir "$project_dir" --non-interactive --version local >/dev/null 2>&1

if ! compgen -G "${project_dir}/.github/prompts/memflow.*.prompt.md" >/dev/null; then
  echo "[FAIL] geração vscode não criou prompts memflow.*.prompt.md"
  exit 1
fi

if compgen -G "${project_dir}/.github/agents/memflow.*.agent.md" >/dev/null; then
  echo "[FAIL] geração vscode criou agentes legados indevidos"
  exit 1
fi

injected_shared=0
for prompt_file in "${project_dir}/.github/prompts/memflow."*.prompt.md; do
  content="$(<"$prompt_file")"
  if [[ "$content" == *"Conteúdo injetado: _shared/base-output.md"* ]] && [[ "$content" == *"Conteúdo injetado: _shared/target-adapter.vscode.md"* ]]; then
    injected_shared=1
    break
  fi
done

if [[ "$injected_shared" -ne 1 ]]; then
  echo "[FAIL] geração vscode não injetou bases compartilhadas esperadas"
  exit 1
fi

echo "[PASS] geração vscode funciona sem erro e com injeção correta"
