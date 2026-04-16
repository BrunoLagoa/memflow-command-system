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

tmp_root="$(mktemp -d)"
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

printf "\nResultado: %d passou, %d falhou\n" "$pass_count" "$fail_count"
if [[ "$fail_count" -gt 0 ]]; then
  exit 1
fi
