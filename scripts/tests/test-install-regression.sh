#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_SCRIPT="${SCRIPT_DIR}/../install.sh"

pass_count=0
fail_count=0

run_expect_exit() {
  local test_name="$1"
  local expected_exit="$2"
  shift 2

  set +e
  "$@" >/tmp/memflow-test.stdout 2>/tmp/memflow-test.stderr
  local exit_code=$?
  set -e

  if [[ "$exit_code" -eq "$expected_exit" ]]; then
    printf "[PASS] %s\n" "$test_name"
    pass_count=$((pass_count + 1))
  else
    printf "[FAIL] %s (esperado exit=%s, recebido=%s)\n" "$test_name" "$expected_exit" "$exit_code"
    fail_count=$((fail_count + 1))
  fi
}

run_expect_success() {
  local test_name="$1"
  shift
  if "$@" >/tmp/memflow-test.stdout 2>/tmp/memflow-test.stderr; then
    printf "[PASS] %s\n" "$test_name"
    pass_count=$((pass_count + 1))
  else
    printf "[FAIL] %s (comando deveria passar)\n" "$test_name"
    fail_count=$((fail_count + 1))
  fi
}

tmp_root="$(mktemp -d "${SCRIPT_DIR}/.tmp-install-regression.XXXXXX")"
cleanup() {
  rm -rf "$tmp_root"
}
trap cleanup EXIT

project_local="${tmp_root}/local-project"
mkdir -p "$project_local"

home_global="${tmp_root}/home-global"
mkdir -p "$home_global"

run_expect_exit \
  "update local sem instalação deve falhar com código 2" \
  2 \
  env HOME="$home_global" bash "$INSTALL_SCRIPT" update --scope local --project-dir "$project_local" --non-interactive --version local

if [[ -d "${project_local}/.opencode/commands/memflow" ]]; then
  printf "[FAIL] update local sem instalação criou diretório indevido\n"
  fail_count=$((fail_count + 1))
else
  printf "[PASS] update local sem instalação não cria diretório\n"
  pass_count=$((pass_count + 1))
fi

run_expect_exit \
  "update global sem instalação deve falhar com código 2" \
  2 \
  env HOME="$home_global" bash "$INSTALL_SCRIPT" update --scope global --non-interactive --version local

run_expect_exit \
  "uninstall local sem instalação deve falhar com código 2" \
  2 \
  env HOME="$home_global" bash "$INSTALL_SCRIPT" uninstall --scope local --project-dir "$project_local" --non-interactive

run_expect_exit \
  "uninstall global sem instalação deve falhar com código 2" \
  2 \
  env HOME="$home_global" bash "$INSTALL_SCRIPT" uninstall --scope global --non-interactive

run_expect_success \
  "install local inicial deve funcionar" \
  env HOME="$home_global" bash "$INSTALL_SCRIPT" install --scope local --project-dir "$project_local" --non-interactive --version local

run_expect_success \
  "update local com instalação existente deve funcionar" \
  env HOME="$home_global" bash "$INSTALL_SCRIPT" update --scope local --project-dir "$project_local" --non-interactive --version local

run_expect_success \
  "install global inicial deve funcionar" \
  env HOME="$home_global" bash "$INSTALL_SCRIPT" install --scope global --non-interactive --version local

run_expect_success \
  "update sem escopo deve funcionar quando global e local existem" \
  env HOME="$home_global" bash "$INSTALL_SCRIPT" update --non-interactive --project-dir "$project_local" --version local

run_expect_success \
  "check sem escopo deve funcionar quando global e local existem" \
  env HOME="$home_global" bash "$INSTALL_SCRIPT" check --non-interactive --project-dir "$project_local"

run_expect_success \
  "uninstall sem escopo deve remover global e local existentes" \
  env HOME="$home_global" bash "$INSTALL_SCRIPT" uninstall --non-interactive --project-dir "$project_local"

if [[ -d "${project_local}/.opencode/commands/memflow" ]]; then
  printf "[FAIL] uninstall sem escopo manteve instalação local\n"
  fail_count=$((fail_count + 1))
else
  printf "[PASS] uninstall sem escopo remove instalação local\n"
  pass_count=$((pass_count + 1))
fi

if [[ -d "${home_global}/.config/opencode/commands/memflow" ]]; then
  printf "[FAIL] uninstall sem escopo manteve instalação global\n"
  fail_count=$((fail_count + 1))
else
  printf "[PASS] uninstall sem escopo remove instalação global\n"
  pass_count=$((pass_count + 1))
fi

run_expect_success \
  "reinstala global para validar fluxo sem local" \
  env HOME="$home_global" bash "$INSTALL_SCRIPT" install --scope global --non-interactive --version local

run_expect_success \
  "update sem escopo com apenas global instalado deve funcionar" \
  env HOME="$home_global" bash "$INSTALL_SCRIPT" update --non-interactive --version local

run_expect_success \
  "check sem escopo com apenas global instalado deve funcionar" \
  env HOME="$home_global" bash "$INSTALL_SCRIPT" check --non-interactive

run_expect_success \
  "uninstall sem escopo com apenas global instalado deve funcionar" \
  env HOME="$home_global" bash "$INSTALL_SCRIPT" uninstall --non-interactive

if [[ -d "${project_local}/.opencode/commands/memflow" ]]; then
  printf "[FAIL] cenário global-only criou instalação local indevida\n"
  fail_count=$((fail_count + 1))
else
  printf "[PASS] cenário global-only não depende de instalação local\n"
  pass_count=$((pass_count + 1))
fi

project_vscode="${tmp_root}/vscode-project"
mkdir -p "$project_vscode"

home_vscode="${tmp_root}/home-vscode"
mkdir -p "$home_vscode"

run_expect_exit \
  "update vscode sem instalação deve falhar com código 2" \
  2 \
  env HOME="$home_vscode" bash "$INSTALL_SCRIPT" update --project-dir "$project_vscode" --target vscode --non-interactive --version local

run_expect_exit \
  "uninstall vscode sem instalação deve falhar com código 2" \
  2 \
  env HOME="$home_vscode" bash "$INSTALL_SCRIPT" uninstall --target vscode --non-interactive --project-dir "$project_vscode"

run_expect_success \
  "install vscode inicial deve funcionar com instalação única" \
  env HOME="$home_vscode" bash "$INSTALL_SCRIPT" install --project-dir "$project_vscode" --target vscode --non-interactive --version local

if compgen -G "${project_vscode}/.github/prompts/memflow.*.prompt.md" >/dev/null; then
  printf "[PASS] install vscode cria prompts em .github/prompts\n"
  pass_count=$((pass_count + 1))
else
  printf "[FAIL] install vscode não criou prompts em .github/prompts\n"
  fail_count=$((fail_count + 1))
fi

if compgen -G "${project_vscode}/.github/agents/memflow.*.agent.md" >/dev/null; then
  printf "[FAIL] install vscode não deve criar agentes em .github/agents\n"
  fail_count=$((fail_count + 1))
else
  printf "[PASS] install vscode não cria agentes em .github/agents\n"
  pass_count=$((pass_count + 1))
fi

shared_path_reference_found=0
base_output_marker_found=0
for prompt_file in "${project_vscode}/.github/prompts/memflow."*.prompt.md; do
  prompt_content="$(<"$prompt_file")"
  if [[ "$prompt_content" == *"~/.config/opencode/commands/memflow/_shared/base-output.md"* ]] || [[ "$prompt_content" == *".opencode/commands/memflow/_shared/base-output.md"* ]]; then
    shared_path_reference_found=1
    break
  fi
  if [[ "$prompt_content" == *"Conteúdo injetado: _shared/base-output.md"* ]]; then
    base_output_marker_found=1
  fi
done

if [[ "$shared_path_reference_found" -eq 1 ]]; then
  printf "[FAIL] install vscode manteve referência de caminho _shared no prompt\n"
  fail_count=$((fail_count + 1))
else
  printf "[PASS] install vscode substitui referências _shared por conteúdo\n"
  pass_count=$((pass_count + 1))
fi

if [[ "$base_output_marker_found" -eq 1 ]]; then
  printf "[PASS] install vscode injeta conteúdo de base-output no prompt\n"
  pass_count=$((pass_count + 1))
else
  printf "[FAIL] install vscode não injetou conteúdo de base-output no prompt\n"
  fail_count=$((fail_count + 1))
fi

run_expect_success \
  "update vscode sem escopo deve funcionar com instalação única" \
  env HOME="$home_vscode" bash "$INSTALL_SCRIPT" update --target vscode --non-interactive --project-dir "$project_vscode" --version local

run_expect_success \
  "check vscode sem escopo deve funcionar com instalação única" \
  env HOME="$home_vscode" bash "$INSTALL_SCRIPT" check --target vscode --non-interactive --project-dir "$project_vscode"

run_expect_success \
  "uninstall vscode sem escopo deve remover global e local existentes" \
  env HOME="$home_vscode" bash "$INSTALL_SCRIPT" uninstall --target vscode --non-interactive --project-dir "$project_vscode"

if [[ -d "${project_vscode}/.vscode/commands/memflow" ]]; then
  printf "[FAIL] uninstall vscode sem escopo manteve instalação legada em .vscode/commands\n"
  fail_count=$((fail_count + 1))
else
  printf "[PASS] uninstall vscode sem escopo remove instalação legada em .vscode/commands\n"
  pass_count=$((pass_count + 1))
fi

if [[ -d "${home_vscode}/.config/vscode/commands/memflow" ]]; then
  printf "[FAIL] vscode criou instalação global indevida\n"
  fail_count=$((fail_count + 1))
else
  printf "[PASS] vscode não usa instalação global\n"
  pass_count=$((pass_count + 1))
fi

if compgen -G "${project_vscode}/.github/agents/memflow.*.agent.md" >/dev/null; then
  printf "[FAIL] uninstall vscode sem escopo manteve agentes legados memflow\n"
  fail_count=$((fail_count + 1))
else
  printf "[PASS] uninstall vscode sem escopo remove agentes legados memflow\n"
  pass_count=$((pass_count + 1))
fi

if compgen -G "${project_vscode}/.github/prompts/memflow.*.prompt.md" >/dev/null; then
  printf "[FAIL] uninstall vscode sem escopo manteve prompts memflow\n"
  fail_count=$((fail_count + 1))
else
  printf "[PASS] uninstall vscode sem escopo remove prompts memflow\n"
  pass_count=$((pass_count + 1))
fi

printf "\nResultado: %d passou, %d falhou\n" "$pass_count" "$fail_count"
if [[ "$fail_count" -gt 0 ]]; then
  exit 1
fi
