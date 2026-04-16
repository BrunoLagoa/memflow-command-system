#!/usr/bin/env bash

set -euo pipefail

MEMFLOW_REPO_DEFAULT="BrunoLagoa/memflow-command-system"
MEMFLOW_SCHEMA_VERSION="1"

color_enabled() {
  if [[ -t 1 ]]; then
    return 0
  fi
  return 1
}

color() {
  local code="$1"
  if color_enabled; then
    printf "\033[%sm" "$code"
  fi
}

color_reset() {
  if color_enabled; then
    printf "\033[0m"
  fi
}

log_info() {
  printf "%s[INFO]%s %s\n" "$(color "36")" "$(color_reset)" "$*"
}

log_warn() {
  printf "%s[WARN]%s %s\n" "$(color "33")" "$(color_reset)" "$*"
}

log_error() {
  printf "%s[ERROR]%s %s\n" "$(color "31")" "$(color_reset)" "$*" 1>&2
}

die() {
  log_error "$*"
  exit 1
}

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
  [[ "$answer" == "y" || "$answer" == "yes" ]]
}

choose_option_tty() {
  local prompt="$1"
  shift
  local options=("$@")
  local idx=1
  local answer=""

  printf "%s\n" "$prompt"
  for option in "${options[@]}"; do
    printf "  %s) %s\n" "$idx" "$option"
    idx=$((idx + 1))
  done

  while true; do
    read_tty "Selecione uma opção [1-${#options[@]}]: " answer
    if [[ "$answer" =~ ^[0-9]+$ ]] && (( answer >= 1 && answer <= ${#options[@]} )); then
      printf "%s" "${options[$((answer - 1))]}"
      return 0
    fi
    log_warn "Opção inválida. Tente novamente."
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
