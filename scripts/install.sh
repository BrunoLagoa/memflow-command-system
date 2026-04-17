#!/usr/bin/env bash

set -euo pipefail

SCRIPT_FILE="${BASH_SOURCE[0]:-}"
SCRIPT_DIR=""
if [[ -n "$SCRIPT_FILE" && -f "$SCRIPT_FILE" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_FILE")" && pwd)"
fi

if [[ -n "$SCRIPT_DIR" && -f "$SCRIPT_DIR/lib/common.sh" ]]; then
  # shellcheck source=./lib/common.sh
  source "$SCRIPT_DIR/lib/common.sh"
else
  MEMFLOW_REPO_DEFAULT="BrunoLagoa/memflow-command-system"
  MEMFLOW_SCHEMA_VERSION="1"
  log_info() { printf "[INFO] %s\n" "$*"; }
  log_warn() { printf "[WARN] %s\n" "$*"; }
  log_error() { printf "[ERROR] %s\n" "$*" 1>&2; }
  die() { log_error "$*"; exit 1; }
  print_memflow_banner() {
    cat <<'EOF'
 __  __ _____ __  __ _____ _     _____        __
|  \/  | ____|  \/  |  ___| |   / _ \ \      / /
| |\/| |  _| | |\/| | |_  | |  | | | \ \ /\ / /
| |  | | |___| |  | |  _| | |__| |_| |\ V  V /
|_|  |_|_____|_|  |_|_|   |_____\___/  \_/\_/
EOF
  }
  read_tty() {
    local prompt="$1"
    local reply_var="$2"
    local reply=""
    if [[ -r /dev/tty ]]; then
      printf "%s" "$prompt" > /dev/tty
      IFS= read -r reply < /dev/tty || true
    else
      printf "%s" "$prompt"
      IFS= read -r reply || true
    fi
    printf -v "$reply_var" "%s" "$reply"
  }
  confirm_tty() {
    local prompt="$1"
    local default_choice="${2:-y}"
    local answer=""
    local suffix="[y/N]"
    if [[ "$default_choice" == "y" ]]; then
      suffix="[Y/n]"
    fi
    read_tty "${prompt} ${suffix}: " answer
    answer="${answer:-$default_choice}"
    answer="$(printf "%s" "$answer" | tr '[:upper:]' '[:lower:]')"
    [[ "$answer" == "y" || "$answer" == "yes" || "$answer" == "s" || "$answer" == "sim" ]]
  }
  choose_option_tty() {
    local prompt="$1"
    shift
    local options=("$@")
    local idx=1
    local answer=""
    if [[ -r /dev/tty ]]; then
      printf "%s\n" "$prompt" > /dev/tty
    else
      printf "%s\n" "$prompt"
    fi
    for option in "${options[@]}"; do
      if [[ -r /dev/tty ]]; then
        printf "  %s) %s\n" "$idx" "$option" > /dev/tty
      else
        printf "  %s) %s\n" "$idx" "$option"
      fi
      idx=$((idx + 1))
    done
    while true; do
      read_tty "Selecione uma opção [1-${#options[@]}]: " answer
      if [[ "$answer" =~ ^[0-9]+$ ]] && (( answer >= 1 && answer <= ${#options[@]} )); then
        printf "%s" "${options[$((answer - 1))]}"
        return 0
      fi
      log_warn "Opção inválida. Tente novamente." >&2
    done
  }
  detect_os() {
    local kernel
    kernel="$(uname -s | tr '[:upper:]' '[:lower:]')"
    case "$kernel" in
      linux*) printf "linux" ;;
      darwin*) printf "macos" ;;
      msys*|mingw*|cygwin*) printf "windows" ;;
      *) printf "linux" ;;
    esac
  }
  ensure_command() {
    local command_name="$1"
    command -v "$command_name" >/dev/null 2>&1 || die "Pré-requisito ausente: $command_name"
  }
  iso_timestamp() {
    date -u +"%Y-%m-%dT%H:%M:%SZ"
  }
fi

ACTION="install"
NON_INTERACTIVE=0
SCOPE=""
TARGET=""
TARGET_EXPLICIT=0
SELECTED_OS=""
VERSION=""
PROJECT_DIR="$(pwd)"
PROJECT_DIR_EXPLICIT=0
REPO="$MEMFLOW_REPO_DEFAULT"
MEMFLOW_REF="${MEMFLOW_REF:-main}"
CHANNEL="release"
BACKUP_ENABLED=1
VERSION_CHECK_TTL_SECONDS=86400
EXIT_CODE_NOT_FOUND=2

load_install_module() {
  local local_relative_path="$1"
  local remote_relative_path="$2"
  local module_path="$SCRIPT_DIR/$local_relative_path"
  if [[ -n "$SCRIPT_DIR" && -f "$module_path" ]]; then
    # shellcheck disable=SC1090
    source "$module_path"
    return 0
  fi

  ensure_command curl
  local module_url="https://raw.githubusercontent.com/${REPO}/${MEMFLOW_REF}/${remote_relative_path}"
  local temp_module
  temp_module="$(mktemp)"
  if ! curl -fsSL "$module_url" -o "$temp_module"; then
    rm -f "$temp_module"
    die "Não foi possível carregar módulo remoto: ${module_url}"
  fi
  # shellcheck disable=SC1090
  source "$temp_module"
  rm -f "$temp_module"
}

load_install_module "installers/bash/core.sh" "scripts/installers/bash/core.sh"
load_install_module "installers/bash/targets/opencode.sh" "scripts/installers/bash/targets/opencode.sh"
load_install_module "installers/bash/targets/vscode.sh" "scripts/installers/bash/targets/vscode.sh"
load_install_module "installers/bash/actions.sh" "scripts/installers/bash/actions.sh"

main() {
  parse_args "$@"
  validate_inputs

  case "$ACTION" in
    install) run_install ;;
    update) run_update ;;
    uninstall) run_uninstall ;;
    check) run_check ;;
  esac
}

main "$@"
