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
TARGET="opencode"
SELECTED_OS=""
VERSION=""
PROJECT_DIR="$(pwd)"
PROJECT_DIR_EXPLICIT=0
REPO="$MEMFLOW_REPO_DEFAULT"
CHANNEL="release"
BACKUP_ENABLED=1
VERSION_CHECK_TTL_SECONDS=86400

usage() {
  cat <<'EOF'
MEMFLOW installer

Uso:
  install.sh [install|update|uninstall|check] [opções]

Opções:
  --non-interactive       Executa sem perguntas interativas
  --scope <global|local>  Escopo de instalação
  --target <opencode>     Plataforma de comandos (atual: opencode)
  --os <linux|macos|windows>
  --version <tag|local>   Versão alvo (tag de release)
  --project-dir <dir>     Diretório do projeto para escopo local
  --repo <owner/repo>     Repositório GitHub (default: BrunoLagoa/memflow-command-system)
  -h, --help              Exibe ajuda

Exemplos:
  ./scripts/install.sh install
  ./scripts/install.sh update --scope global
  ./scripts/install.sh uninstall --scope local --project-dir .
  ./scripts/install.sh check --scope global --non-interactive
EOF
}

parse_args() {
  if [[ $# -gt 0 && "${1#-}" == "$1" ]]; then
    ACTION="$1"
    shift
  fi

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --non-interactive)
        NON_INTERACTIVE=1
        shift
        ;;
      --scope)
        SCOPE="${2:-}"
        shift 2
        ;;
      --target)
        TARGET="${2:-}"
        shift 2
        ;;
      --os)
        SELECTED_OS="${2:-}"
        shift 2
        ;;
      --version)
        VERSION="${2:-}"
        shift 2
        ;;
      --project-dir)
        PROJECT_DIR="${2:-}"
        PROJECT_DIR_EXPLICIT=1
        shift 2
        ;;
      --repo)
        REPO="${2:-}"
        shift 2
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        die "Argumento desconhecido: $1"
        ;;
    esac
  done
}

validate_inputs() {
  case "$ACTION" in
    install|update|uninstall|check) ;;
    *) die "Ação inválida: $ACTION" ;;
  esac

  case "$TARGET" in
    opencode) ;;
    *) die "Target não suportado: $TARGET" ;;
  esac

  if [[ -n "$SCOPE" ]]; then
    case "$SCOPE" in
      global|local) ;;
      *) die "Scope inválido: $SCOPE" ;;
    esac
  fi

  if [[ -n "$SELECTED_OS" ]]; then
    case "$SELECTED_OS" in
      linux|macos|windows) ;;
      *) die "Sistema operacional inválido: $SELECTED_OS" ;;
    esac
  fi
}

wizard_select() {
  local detected_os
  detected_os="$(detect_os)"

  print_memflow_banner
  printf "\nMEMFLOW - Sistema open source de engenharia com IA para SDLC (Software Development Life Cycle) completo e automação de comandos em múltiplas plataformas.\nUm conjunto de ferramentas de código aberto para focar em cenários de produto e resultados previsíveis, em vez de desenvolver cada parte do zero com base em intuição.\n\n"

  if [[ -z "$SELECTED_OS" ]]; then
    log_info "SO detectado automaticamente: $detected_os"
    if confirm_tty "1 - O sistema operacional detectado (${detected_os}) está correto?" "y"; then
      SELECTED_OS="$detected_os"
    else
      SELECTED_OS="$(choose_option_tty "1 - Escolha seu sistema operacional" "linux" "macos" "windows")"
    fi
  fi

  if [[ -z "$TARGET" ]]; then
    TARGET="$(choose_option_tty "2 - Selecione o local de instalação" "opencode")"
  else
    printf "2 - Selecione o local de instalação\n  > %s\n" "$TARGET"
  fi

  if [[ -z "$SCOPE" ]]; then
    SCOPE="$(choose_option_tty "3 - Essa instalação vai ser local ou global?" "local" "global")"
  fi
}

default_missing_values() {
  if [[ -z "$SELECTED_OS" ]]; then
    SELECTED_OS="$(detect_os)"
  fi
  if [[ -z "$SCOPE" ]]; then
    SCOPE="global"
  fi
  if [[ -z "$TARGET" ]]; then
    TARGET="opencode"
  fi
}

commands_root_for_scope() {
  local scope="$1"
  local os_name="$2"
  local project_dir="$3"
  local root=""

  if [[ "$scope" == "global" ]]; then
    if [[ "$os_name" == "windows" && -n "${USERPROFILE:-}" ]]; then
      root="${USERPROFILE}/.config/opencode/commands"
    else
      root="${HOME}/.config/opencode/commands"
    fi
  else
    root="${project_dir}/.opencode/commands"
  fi

  printf "%s" "$root"
}

parse_manifest_value() {
  local file="$1"
  local key="$2"
  sed -n "s/.*\"${key}\":[[:space:]]*\"\([^\"]*\)\".*/\1/p" "$file" | head -n 1
}

find_existing_manifest() {
  local os_name="$1"
  local project_dir="$2"
  local global_root local_root
  global_root="$(commands_root_for_scope "global" "$os_name" "$project_dir")"
  local_root="$(commands_root_for_scope "local" "$os_name" "$project_dir")"

  if [[ -f "${global_root}/.memflow-install.json" ]]; then
    printf "%s" "${global_root}/.memflow-install.json"
    return 0
  fi

  if [[ -f "${local_root}/.memflow-install.json" ]]; then
    printf "%s" "${local_root}/.memflow-install.json"
    return 0
  fi

  return 1
}

fetch_latest_release_tag() {
  ensure_command curl
  local api_url="https://api.github.com/repos/${REPO}/releases/latest"
  local tag=""
  tag="$(curl -fsSL "$api_url" | sed -n 's/.*"tag_name":[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)"
  if [[ -z "$tag" ]]; then
    die "Não foi possível descobrir a release mais recente em ${REPO}."
  fi
  printf "%s" "$tag"
}

fetch_latest_release_tag_safe() {
  local repo_name="$1"
  ensure_command curl
  local api_url="https://api.github.com/repos/${repo_name}/releases/latest"
  local tag=""
  tag="$(curl -fsSL "$api_url" 2>/dev/null | sed -n 's/.*"tag_name":[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1 || true)"
  if [[ -z "$tag" ]]; then
    return 1
  fi
  printf "%s" "$tag"
}

version_cache_file_for_os() {
  local os_name="$1"
  if [[ "$os_name" == "windows" && -n "${LOCALAPPDATA:-}" ]]; then
    printf "%s/memflow/version-check.json" "${LOCALAPPDATA}"
    return 0
  fi
  printf "%s/.cache/memflow/version-check.json" "${HOME}"
}

parse_json_value() {
  local file="$1"
  local key="$2"
  sed -n "s/.*\"${key}\":[[:space:]]*\"\([^\"]*\)\".*/\1/p" "$file" | head -n 1
}

write_version_cache() {
  local cache_file="$1"
  local repo_name="$2"
  local latest_version="$3"
  local now_epoch="$4"
  local cache_dir
  cache_dir="$(dirname "$cache_file")"
  mkdir -p "$cache_dir"
  cat > "$cache_file" <<EOF
{
  "repo": "${repo_name}",
  "latestVersion": "${latest_version}",
  "lastCheckedEpoch": "${now_epoch}"
}
EOF
}

is_cache_valid() {
  local cache_file="$1"
  local repo_name="$2"
  if [[ ! -f "$cache_file" ]]; then
    return 1
  fi

  local cached_repo cached_epoch now_epoch delta
  cached_repo="$(parse_json_value "$cache_file" "repo")"
  cached_epoch="$(parse_json_value "$cache_file" "lastCheckedEpoch")"
  if [[ -z "$cached_repo" || "$cached_repo" != "$repo_name" ]]; then
    return 1
  fi
  if [[ ! "$cached_epoch" =~ ^[0-9]+$ ]]; then
    return 1
  fi
  now_epoch="$(date +%s)"
  delta=$((now_epoch - cached_epoch))
  (( delta >= 0 && delta <= VERSION_CHECK_TTL_SECONDS ))
}

resolve_latest_version_with_cache() {
  local repo_name="$1"
  local os_name="$2"
  local cache_file cached_version fetched_version now_epoch
  cache_file="$(version_cache_file_for_os "$os_name")"

  if is_cache_valid "$cache_file" "$repo_name"; then
    cached_version="$(parse_json_value "$cache_file" "latestVersion")"
    if [[ -n "$cached_version" ]]; then
      printf "%s" "$cached_version"
      return 0
    fi
  fi

  fetched_version="$(fetch_latest_release_tag_safe "$repo_name" || true)"
  if [[ -z "$fetched_version" ]]; then
    return 1
  fi

  now_epoch="$(date +%s)"
  write_version_cache "$cache_file" "$repo_name" "$fetched_version" "$now_epoch"
  printf "%s" "$fetched_version"
}

normalize_version() {
  local value="$1"
  value="${value#v}"
  value="${value#V}"
  printf "%s" "$value"
}

is_version_newer() {
  local latest="$1"
  local installed="$2"
  local latest_norm installed_norm highest
  latest_norm="$(normalize_version "$latest")"
  installed_norm="$(normalize_version "$installed")"
  if [[ -z "$latest_norm" || -z "$installed_norm" || "$latest_norm" == "$installed_norm" ]]; then
    return 1
  fi
  highest="$(printf "%s\n%s\n" "$installed_norm" "$latest_norm" | sort -V | tail -n 1)"
  [[ "$highest" == "$latest_norm" ]]
}

print_version_update_notice() {
  local installed_version="$1"
  local latest_version="$2"
  local scope_value="$3"
  local os_name="$4"
  local update_command="memflowctl update --scope ${scope_value} --non-interactive"
  if [[ "$os_name" == "windows" ]]; then
    update_command="memflowctl.ps1 update -Scope ${scope_value} -NonInteractive"
  fi

  log_info "Nova versão do MEMFLOW disponível."
  printf "  Versão atual: %s\n" "$installed_version"
  printf "  Última versão: %s\n" "$latest_version"
  printf "  Próximo passo: %s\n" "$update_command"
}

resolve_source_dir() {
  local requested_version="$1"
  local tmp_dir
  tmp_dir="$(mktemp -d)"

  if [[ "$requested_version" == "local" ]]; then
    if [[ -z "$SCRIPT_DIR" ]]; then
      die "Não foi possível resolver instalação local sem caminho do script."
    fi
    local repo_root
    repo_root="$(cd "$SCRIPT_DIR/.." && pwd)"
    local local_src="${repo_root}/src"
    [[ -d "$local_src" ]] || die "Diretório src não encontrado para instalação local."
    printf "%s" "$local_src"
    return 0
  fi

  ensure_command curl
  ensure_command tar

  local archive_url="https://github.com/${REPO}/archive/refs/tags/${requested_version}.tar.gz"
  local archive_file="${tmp_dir}/release.tar.gz"
  curl -fsSL "$archive_url" -o "$archive_file" || die "Falha ao baixar release ${requested_version}."
  tar -xzf "$archive_file" -C "$tmp_dir"

  local extracted_root=""
  extracted_root="$(ls -1d "${tmp_dir}"/* 2>/dev/null | head -n 1 || true)"
  [[ -n "$extracted_root" && -d "$extracted_root/src" ]] || die "Conteúdo da release inválido."
  printf "%s" "${extracted_root}/src"
}

write_manifest() {
  local manifest_file="$1"
  local version="$2"
  local scope="$3"
  local target="$4"
  local os_name="$5"
  local install_dir="$6"
  local commands_root="$7"

  cat > "$manifest_file" <<EOF
{
  "schemaVersion": "${MEMFLOW_SCHEMA_VERSION}",
  "project": "memflow-command-system",
  "version": "${version}",
  "scope": "${scope}",
  "target": "${target}",
  "channel": "${CHANNEL}",
  "repo": "${REPO}",
  "os": "${os_name}",
  "installDir": "${install_dir}",
  "commandsRoot": "${commands_root}",
  "installedAt": "$(iso_timestamp)"
}
EOF
}

perform_install() {
  local commands_root="$1"
  local install_dir="$2"
  local manifest_file="$3"
  local version="$4"

  local source_dir
  source_dir="$(resolve_source_dir "$version")"

  mkdir -p "$commands_root"

  if [[ -d "$install_dir" ]]; then
    if [[ "$BACKUP_ENABLED" -eq 1 && "$NON_INTERACTIVE" -eq 0 ]] && confirm_tty "Instalação existente detectada em ${install_dir}. Deseja criar backup?" "y"; then
      local backup_dir="${install_dir}.bak.$(date +%Y%m%d%H%M%S)"
      cp -R "$install_dir" "$backup_dir"
      log_info "Backup criado em ${backup_dir}"
    fi
    rm -rf "$install_dir"
  fi

  mkdir -p "$install_dir"
  cp -R "${source_dir}/." "$install_dir/"
  write_manifest "$manifest_file" "$version" "$SCOPE" "$TARGET" "$SELECTED_OS" "$install_dir" "$commands_root"

  log_info "Instalação concluída com sucesso."
  log_info "Destino: ${install_dir}"
  log_info "Próximos passos: /context e /workflow"
}

run_install() {
  BACKUP_ENABLED=1
  if [[ "$NON_INTERACTIVE" -eq 0 ]]; then
    wizard_select
  else
    default_missing_values
  fi

  local commands_root
  commands_root="$(commands_root_for_scope "$SCOPE" "$SELECTED_OS" "$PROJECT_DIR")"
  local install_dir="${commands_root}/memflow"
  local manifest_file="${commands_root}/.memflow-install.json"

  local resolved_version="$VERSION"
  if [[ -z "$resolved_version" ]]; then
    resolved_version="$(fetch_latest_release_tag)"
  fi

  printf "\nResumo da instalação\n"
  printf "  Sistema operacional: %s\n" "$SELECTED_OS"
  printf "  Target: %s\n" "$TARGET"
  printf "  Scope: %s\n" "$SCOPE"
  printf "  Versão: %s\n" "$resolved_version"
  printf "  Destino: %s\n\n" "$install_dir"

  if [[ "$NON_INTERACTIVE" -eq 0 ]] && ! confirm_tty "Confirmar instalação?" "y"; then
    log_warn "Instalação cancelada pelo usuário."
    exit 0
  fi

  perform_install "$commands_root" "$install_dir" "$manifest_file" "$resolved_version"
}

run_update() {
  local user_scope="${SCOPE:-}"
  BACKUP_ENABLED=0
  default_missing_values
  local commands_root manifest_file existing_manifest=""
  commands_root="$(commands_root_for_scope "$SCOPE" "$SELECTED_OS" "$PROJECT_DIR")"
  manifest_file="${commands_root}/.memflow-install.json"

  local installed_version=""

  if [[ -z "$user_scope" ]]; then
    existing_manifest="$(find_existing_manifest "$SELECTED_OS" "$PROJECT_DIR" || true)"
    if [[ -n "$existing_manifest" ]]; then
      manifest_file="$existing_manifest"
    fi
  fi

  if [[ -f "$manifest_file" ]]; then
    installed_version="$(parse_manifest_value "$manifest_file" "version")"
    SCOPE="${SCOPE:-$(parse_manifest_value "$manifest_file" "scope")}"
    TARGET="${TARGET:-$(parse_manifest_value "$manifest_file" "target")}"
    SELECTED_OS="${SELECTED_OS:-$(parse_manifest_value "$manifest_file" "os")}"
    if [[ -z "$VERSION" ]]; then
      VERSION="$(fetch_latest_release_tag)"
    fi
  else
    if [[ "$SCOPE" == "local" && "$PROJECT_DIR_EXPLICIT" -eq 0 ]]; then
      die "Para atualizar instalação local fora do projeto atual, informe --project-dir <dir>."
    fi
    [[ -n "$SCOPE" ]] || SCOPE="global"
    [[ -n "$SELECTED_OS" ]] || SELECTED_OS="$(detect_os)"
    [[ -n "$VERSION" ]] || VERSION="$(fetch_latest_release_tag)"
  fi

  local updated_root
  updated_root="$(commands_root_for_scope "$SCOPE" "$SELECTED_OS" "$PROJECT_DIR")"
  local install_dir="${updated_root}/memflow"
  local manifest_updated="${updated_root}/.memflow-install.json"

  if [[ -n "$installed_version" && "$installed_version" == "$VERSION" ]]; then
    log_info "MEMFLOW já está na versão mais recente (${installed_version}). Nenhuma atualização é necessária agora."
    return 0
  fi

  log_info "Recomendando atualização do MEMFLOW para versão ${VERSION}"
  perform_install "$updated_root" "$install_dir" "$manifest_updated" "$VERSION"
}

run_uninstall() {
  local user_scope="${SCOPE:-}"
  default_missing_values
  local commands_root install_dir manifest_file existing_manifest=""
  commands_root="$(commands_root_for_scope "$SCOPE" "$SELECTED_OS" "$PROJECT_DIR")"
  install_dir="${commands_root}/memflow"
  manifest_file="${commands_root}/.memflow-install.json"

  if [[ -z "$user_scope" ]]; then
    existing_manifest="$(find_existing_manifest "$SELECTED_OS" "$PROJECT_DIR" || true)"
    if [[ -n "$existing_manifest" ]]; then
      manifest_file="$existing_manifest"
      commands_root="$(dirname "$manifest_file")"
      install_dir="${commands_root}/memflow"
    fi
  fi

  if [[ ! -d "$install_dir" && ! -f "$manifest_file" ]]; then
    if [[ "${SCOPE:-}" == "local" && "$PROJECT_DIR_EXPLICIT" -eq 0 ]]; then
      die "Para remover instalação local fora do projeto atual, informe --project-dir <dir>."
    fi
    log_warn "Nenhuma instalação MEMFLOW encontrada em ${commands_root}."
    exit 0
  fi

  printf "Destino de remoção: %s\n" "$install_dir"
  if [[ "$NON_INTERACTIVE" -eq 0 ]] && ! confirm_tty "Confirmar remoção completa do MEMFLOW?" "n"; then
    log_warn "Remoção cancelada pelo usuário."
    exit 0
  fi

  rm -rf "$install_dir"
  rm -f "$manifest_file"
  log_info "MEMFLOW removido com sucesso."
}

run_check() {
  local user_scope="${SCOPE:-}"
  local os_name="${SELECTED_OS:-$(detect_os)}"
  local manifest_file=""
  if [[ -n "$user_scope" ]]; then
    local commands_root
    commands_root="$(commands_root_for_scope "$user_scope" "$os_name" "$PROJECT_DIR")"
    manifest_file="${commands_root}/.memflow-install.json"
  else
    manifest_file="$(find_existing_manifest "$os_name" "$PROJECT_DIR" || true)"
  fi

  if [[ -z "$manifest_file" || ! -f "$manifest_file" ]]; then
    return 0
  fi

  local installed_version installed_scope installed_os installed_repo
  installed_version="$(parse_manifest_value "$manifest_file" "version")"
  installed_scope="$(parse_manifest_value "$manifest_file" "scope")"
  installed_os="$(parse_manifest_value "$manifest_file" "os")"
  installed_repo="$(parse_manifest_value "$manifest_file" "repo")"

  if [[ -z "$installed_version" ]]; then
    return 0
  fi

  local effective_scope effective_os repo_name latest_version
  effective_scope="${installed_scope:-${SCOPE:-global}}"
  effective_os="${installed_os:-$os_name}"
  repo_name="${installed_repo:-$REPO}"

  latest_version="$(resolve_latest_version_with_cache "$repo_name" "$effective_os" || true)"
  if [[ -z "$latest_version" ]]; then
    return 0
  fi

  if is_version_newer "$latest_version" "$installed_version"; then
    print_version_update_notice "$installed_version" "$latest_version" "$effective_scope" "$effective_os"
  fi
}

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
