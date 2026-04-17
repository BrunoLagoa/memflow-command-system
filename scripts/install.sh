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
CHANNEL="release"
BACKUP_ENABLED=1
VERSION_CHECK_TTL_SECONDS=86400
EXIT_CODE_NOT_FOUND=2

normalize_scope_for_target() {
  local requested_scope="$1"
  local target="$2"
  if [[ "$target" == "vscode" ]]; then
    # VS Code usa instalação única por projeto.
    printf "local"
    return 0
  fi
  printf "%s" "$requested_scope"
}

install_dir_for_target() {
  local commands_root="$1"
  local target="$2"
  if [[ "$target" == "vscode" ]]; then
    printf "%s" "${commands_root}/prompts"
    return 0
  fi
  printf "%s" "${commands_root}/memflow"
}

die_with_code() {
  local exit_code="$1"
  shift
  log_error "$*"
  exit "$exit_code"
}

missing_installation_message() {
  local action_name="$1"
  local resolved_scope="$2"
  local explicit_scope="$3"
  if [[ -n "$explicit_scope" ]]; then
    printf "Não é possível executar %s: nenhuma instalação MEMFLOW encontrada no escopo %s." "$action_name" "$resolved_scope"
    return 0
  fi
  printf "Não é possível executar %s: nenhuma instalação MEMFLOW encontrada." "$action_name"
}

prompt_fresh_install_from_update() {
  local explicit_scope="$1"
  local message=""
  message="$(missing_installation_message "update" "$SCOPE" "$explicit_scope")"

  if [[ "$NON_INTERACTIVE" -eq 1 ]]; then
    return 1
  fi

  log_warn "$message"
  if ! confirm_tty "Deseja iniciar uma nova instalação agora?" "n"; then
    return 1
  fi

  local resolved_version="$VERSION"
  if [[ -z "$resolved_version" ]]; then
    resolved_version="$(fetch_latest_release_tag)"
  fi

  local commands_root install_dir manifest_file
  commands_root="$(commands_root_for_scope "$SCOPE" "$TARGET" "$SELECTED_OS" "$PROJECT_DIR")"
  install_dir="$(install_dir_for_target "$commands_root" "$TARGET")"
  manifest_file="${commands_root}/.memflow-install.json"

  log_info "Iniciando nova instalação no escopo ${SCOPE}."
  perform_install "$commands_root" "$install_dir" "$manifest_file" "$resolved_version"
  return 0
}

usage() {
  cat <<'EOF'
MEMFLOW installer

Uso:
  install.sh [install|update|uninstall|check] [opções]

Opções:
  --non-interactive       Executa sem perguntas interativas
  --scope <global|local>  Escopo de instalação
  --target <opencode|vscode>  Plataforma de comandos
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
        TARGET_EXPLICIT=1
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

  if [[ -n "$TARGET" ]] && ! is_supported_target "$TARGET"; then
    die "Target não suportado: $TARGET"
  fi

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

supported_targets() {
  printf "%s\n" "opencode" "vscode"
}

is_supported_target() {
  local target="$1"
  case "$target" in
    opencode|vscode) return 0 ;;
    *) return 1 ;;
  esac
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
    TARGET="$(choose_option_tty "2 - Selecione o local de instalação" "opencode" "vscode")"
  else
    printf "2 - Selecione o local de instalação\n  > %s\n" "$TARGET"
  fi

  if [[ -z "$SCOPE" ]]; then
    if [[ "$TARGET" == "vscode" ]]; then
      SCOPE="local"
      printf "3 - Escopo\n  > local (único para vscode)\n"
    else
      SCOPE="$(choose_option_tty "3 - Essa instalação vai ser local ou global?" "local" "global")"
    fi
  fi

  SCOPE="$(normalize_scope_for_target "$SCOPE" "$TARGET")"
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
  SCOPE="$(normalize_scope_for_target "$SCOPE" "$TARGET")"
}

commands_root_for_scope() {
  local scope="$1"
  local target="$2"
  local os_name="$3"
  local project_dir="$4"
  local root=""

  if [[ "$target" == "vscode" ]]; then
    printf "%s" "${project_dir}/.github"
    return 0
  fi

  if [[ "$scope" == "global" ]]; then
    if [[ "$os_name" == "windows" && -n "${USERPROFILE:-}" ]]; then
      root="${USERPROFILE}/.config/${target}/commands"
    else
      root="${HOME}/.config/${target}/commands"
    fi
  else
    root="${project_dir}/.${target}/commands"
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
  local target_filter="${3:-}"
  local target global_root local_root
  while IFS= read -r target; do
    [[ -n "$target_filter" && "$target" != "$target_filter" ]] && continue
    if [[ "$target" == "vscode" ]]; then
      local_root="$(commands_root_for_scope "local" "$target" "$os_name" "$project_dir")"
      if [[ -f "${local_root}/.memflow-install.json" ]]; then
        printf "%s" "${local_root}/.memflow-install.json"
        return 0
      fi
      continue
    fi
    global_root="$(commands_root_for_scope "global" "$target" "$os_name" "$project_dir")"
    local_root="$(commands_root_for_scope "local" "$target" "$os_name" "$project_dir")"

    if [[ -f "${global_root}/.memflow-install.json" ]]; then
      printf "%s" "${global_root}/.memflow-install.json"
      return 0
    fi

    if [[ -f "${local_root}/.memflow-install.json" ]]; then
      printf "%s" "${local_root}/.memflow-install.json"
      return 0
    fi
  done < <(supported_targets)

  if [[ -n "$target_filter" ]] && ! is_supported_target "$target_filter"; then
    return 1
  fi

  return 1
}

collect_existing_manifests() {
  local os_name="$1"
  local project_dir="$2"
  local target_filter="${3:-}"
  local target global_root local_root
  while IFS= read -r target; do
    [[ -n "$target_filter" && "$target" != "$target_filter" ]] && continue
    if [[ "$target" == "vscode" ]]; then
      local_root="$(commands_root_for_scope "local" "$target" "$os_name" "$project_dir")"
      if [[ -f "${local_root}/.memflow-install.json" ]]; then
        printf "%s\n" "${local_root}/.memflow-install.json"
      fi
      continue
    fi
    global_root="$(commands_root_for_scope "global" "$target" "$os_name" "$project_dir")"
    local_root="$(commands_root_for_scope "local" "$target" "$os_name" "$project_dir")"

    if [[ -f "${global_root}/.memflow-install.json" ]]; then
      printf "%s\n" "${global_root}/.memflow-install.json"
    fi

    if [[ -f "${local_root}/.memflow-install.json" ]]; then
      printf "%s\n" "${local_root}/.memflow-install.json"
    fi
  done < <(supported_targets)
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
  local target_value="$5"
  local update_command="memflowctl update --scope ${scope_value} --non-interactive"
  if [[ "$target_value" == "vscode" ]]; then
    update_command="memflowctl update --target vscode --project-dir . --non-interactive"
  elif [[ "$os_name" == "windows" ]]; then
    update_command="memflowctl.ps1 update -Scope ${scope_value} -NonInteractive"
  fi

  log_info "Nova versão do MEMFLOW encontrada. Atual: ${installed_version} | Disponível: ${latest_version}"
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

render_vscode_prompt_with_shared() {
  local src_file="$1"
  local dest_file="$2"
  local source_dir="$3"
  local shared_dir="${source_dir}/_shared"
  local shared_output="${shared_dir}/base-output.md"
  local shared_preconditions="${shared_dir}/base-preconditions.md"
  local shared_degraded="${shared_dir}/base-degraded-mode.md"

  [[ -f "$shared_output" ]] || die "Arquivo compartilhado não encontrado: ${shared_output}"
  [[ -f "$shared_preconditions" ]] || die "Arquivo compartilhado não encontrado: ${shared_preconditions}"
  [[ -f "$shared_degraded" ]] || die "Arquivo compartilhado não encontrado: ${shared_degraded}"

  awk \
    -v shared_output_file="$shared_output" \
    -v shared_preconditions_file="$shared_preconditions" \
    -v shared_degraded_file="$shared_degraded" '
      function inject_file(path, title,   line) {
        print title
        while ((getline line < path) > 0) {
          print line
        }
        close(path)
      }
      {
        if ($0 ~ /_shared\/base-output\.md/) {
          inject_file(shared_output_file, "### Conteúdo injetado: _shared/base-output.md")
          next
        }
        if ($0 ~ /_shared\/base-preconditions\.md/) {
          inject_file(shared_preconditions_file, "### Conteúdo injetado: _shared/base-preconditions.md")
          next
        }
        if ($0 ~ /_shared\/base-degraded-mode\.md/) {
          inject_file(shared_degraded_file, "### Conteúdo injetado: _shared/base-degraded-mode.md")
          next
        }
        print
      }
    ' "$src_file" > "$dest_file"
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

  if [[ "$TARGET" == "vscode" ]]; then
    local prompts_dir legacy_agents_dir src_file stem prompt_file
    prompts_dir="${commands_root}/prompts"
    legacy_agents_dir="${commands_root}/agents"
    mkdir -p "$prompts_dir"

    if [[ "$BACKUP_ENABLED" -eq 1 && "$NON_INTERACTIVE" -eq 0 ]] && { compgen -G "${prompts_dir}/memflow.*.prompt.md" >/dev/null || compgen -G "${legacy_agents_dir}/memflow.*.agent.md" >/dev/null; }; then
      if confirm_tty "Comandos MEMFLOW existentes detectados para VSCode. Deseja criar backup?" "y"; then
        local backup_dir="${commands_root}/memflow-vscode-backup.$(date +%Y%m%d%H%M%S)"
        mkdir -p "$backup_dir"
        cp -R "$prompts_dir" "$backup_dir/prompts" 2>/dev/null || true
        cp -R "$legacy_agents_dir" "$backup_dir/agents" 2>/dev/null || true
        log_info "Backup criado em ${backup_dir}"
      fi
    fi

    rm -f "${prompts_dir}/memflow."*.prompt.md
    rm -f "${legacy_agents_dir}/memflow."*.agent.md

    local generated_count=0
    shopt -s nullglob
    for src_file in "${source_dir}"/*.md; do
      stem="$(basename "$src_file" .md)"
      prompt_file="${prompts_dir}/memflow.${stem}.prompt.md"
      render_vscode_prompt_with_shared "$src_file" "$prompt_file" "$source_dir"
      generated_count=$((generated_count + 1))
    done
    shopt -u nullglob

    if [[ "$generated_count" -eq 0 ]]; then
      die "Nenhum comando encontrado em ${source_dir} para instalação VSCode."
    fi

    local manifest_scope
    manifest_scope="$(normalize_scope_for_target "$SCOPE" "$TARGET")"
    write_manifest "$manifest_file" "$version" "$manifest_scope" "$TARGET" "$SELECTED_OS" "$prompts_dir" "$commands_root"

    log_info "Instalação concluída com sucesso."
    log_info "Destino prompts: ${prompts_dir}"
    return 0
  fi

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
  local manifest_scope
  manifest_scope="$(normalize_scope_for_target "$SCOPE" "$TARGET")"
  write_manifest "$manifest_file" "$version" "$manifest_scope" "$TARGET" "$SELECTED_OS" "$install_dir" "$commands_root"

  log_info "Instalação concluída com sucesso."
  log_info "Destino: ${install_dir}"
}

run_install() {
  BACKUP_ENABLED=1
  if [[ "$NON_INTERACTIVE" -eq 0 ]]; then
    wizard_select
  else
    default_missing_values
  fi

  SCOPE="$(normalize_scope_for_target "$SCOPE" "$TARGET")"

  local commands_root
  commands_root="$(commands_root_for_scope "$SCOPE" "$TARGET" "$SELECTED_OS" "$PROJECT_DIR")"
  local install_dir
  install_dir="$(install_dir_for_target "$commands_root" "$TARGET")"
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
  local target_filter=""
  if [[ "$TARGET_EXPLICIT" -eq 1 ]]; then
    target_filter="$TARGET"
  fi
  BACKUP_ENABLED=0
  default_missing_values
  local commands_root manifest_file existing_manifest=""
  commands_root="$(commands_root_for_scope "$SCOPE" "$TARGET" "$SELECTED_OS" "$PROJECT_DIR")"
  manifest_file="${commands_root}/.memflow-install.json"
  local -a manifests_to_update=()

  local installed_version=""
  if [[ -z "$VERSION" ]]; then
    VERSION="$(fetch_latest_release_tag)"
  fi

  if [[ -z "$user_scope" ]]; then
    while IFS= read -r existing_manifest; do
      [[ -n "$existing_manifest" ]] && manifests_to_update+=("$existing_manifest")
    done < <(collect_existing_manifests "$SELECTED_OS" "$PROJECT_DIR" "$target_filter")

    if [[ "${#manifests_to_update[@]}" -eq 0 ]]; then
      if prompt_fresh_install_from_update "$user_scope"; then
        return 0
      fi
      die_with_code "$EXIT_CODE_NOT_FOUND" "$(missing_installation_message "update" "$SCOPE" "$user_scope")"
    fi

    local updated_count=0
    for manifest_file in "${manifests_to_update[@]}"; do
      installed_version="$(parse_manifest_value "$manifest_file" "version")"
      local manifest_scope manifest_target manifest_os
      manifest_scope="$(parse_manifest_value "$manifest_file" "scope")"
      manifest_target="$(parse_manifest_value "$manifest_file" "target")"
      manifest_os="$(parse_manifest_value "$manifest_file" "os")"
      if [[ -n "$manifest_scope" ]]; then
        SCOPE="$manifest_scope"
      fi
      if [[ -n "$manifest_target" ]]; then
        TARGET="$manifest_target"
      fi
      SCOPE="$(normalize_scope_for_target "$SCOPE" "$TARGET")"
      if [[ -n "$manifest_os" ]]; then
        SELECTED_OS="$manifest_os"
      fi

      local updated_root install_dir manifest_updated
      updated_root="$(commands_root_for_scope "$SCOPE" "$TARGET" "$SELECTED_OS" "$PROJECT_DIR")"
      install_dir="$(install_dir_for_target "$updated_root" "$TARGET")"
      manifest_updated="${updated_root}/.memflow-install.json"

      if [[ -n "$installed_version" && "$installed_version" == "$VERSION" ]]; then
        log_info "[$SCOPE] MEMFLOW já está atualizado (${installed_version})"
        continue
      fi

      if [[ -n "$installed_version" ]]; then
        log_info "[$SCOPE] Nova versão do MEMFLOW encontrada. Atual: ${installed_version} | Disponível: ${VERSION}"
      else
        log_info "[$SCOPE] Atualização do MEMFLOW iniciada para versão ${VERSION}"
      fi
      perform_install "$updated_root" "$install_dir" "$manifest_updated" "$VERSION"
      updated_count=$((updated_count + 1))
    done
    if [[ "$updated_count" -gt 0 ]]; then
      log_info "Atualização concluída em ${updated_count} escopo(s)."
    fi
    return 0
  fi

  if [[ -f "$manifest_file" ]]; then
    installed_version="$(parse_manifest_value "$manifest_file" "version")"
    local manifest_scope manifest_target manifest_os
    manifest_scope="$(parse_manifest_value "$manifest_file" "scope")"
    manifest_target="$(parse_manifest_value "$manifest_file" "target")"
    manifest_os="$(parse_manifest_value "$manifest_file" "os")"
    if [[ -n "$manifest_scope" ]]; then
      SCOPE="$manifest_scope"
    fi
    if [[ -n "$manifest_target" ]]; then
      TARGET="$manifest_target"
    fi
    SCOPE="$(normalize_scope_for_target "$SCOPE" "$TARGET")"
    if [[ -n "$manifest_os" ]]; then
      SELECTED_OS="$manifest_os"
    fi
  else
    if [[ "$SCOPE" == "local" && "$PROJECT_DIR_EXPLICIT" -eq 0 ]]; then
      die "Para atualizar instalação local fora do projeto atual, informe --project-dir <dir>."
    fi
    if prompt_fresh_install_from_update "$user_scope"; then
      return 0
    fi
    die_with_code "$EXIT_CODE_NOT_FOUND" "$(missing_installation_message "update" "$SCOPE" "$user_scope")"
  fi

  local updated_root
  updated_root="$(commands_root_for_scope "$SCOPE" "$TARGET" "$SELECTED_OS" "$PROJECT_DIR")"
  local install_dir
  install_dir="$(install_dir_for_target "$updated_root" "$TARGET")"
  local manifest_updated="${updated_root}/.memflow-install.json"

  if [[ -n "$installed_version" && "$installed_version" == "$VERSION" ]]; then
    log_info "MEMFLOW já está atualizado (${installed_version})"
    return 0
  fi

  if [[ -n "$installed_version" ]]; then
    log_info "Nova versão do MEMFLOW encontrada. Atual: ${installed_version} | Disponível: ${VERSION}"
  else
    log_info "Atualização do MEMFLOW iniciada para versão ${VERSION}"
  fi
  perform_install "$updated_root" "$install_dir" "$manifest_updated" "$VERSION"
}

run_uninstall() {
  local user_scope="${SCOPE:-}"
  local target_filter=""
  if [[ "$TARGET_EXPLICIT" -eq 1 ]]; then
    target_filter="$TARGET"
  fi
  default_missing_values
  local commands_root install_dir manifest_file existing_manifest=""
  commands_root="$(commands_root_for_scope "$SCOPE" "$TARGET" "$SELECTED_OS" "$PROJECT_DIR")"
  install_dir="$(install_dir_for_target "$commands_root" "$TARGET")"
  manifest_file="${commands_root}/.memflow-install.json"
  local -a manifests_to_remove=()

  if [[ -z "$user_scope" ]]; then
    while IFS= read -r existing_manifest; do
      [[ -n "$existing_manifest" ]] && manifests_to_remove+=("$existing_manifest")
    done < <(collect_existing_manifests "$SELECTED_OS" "$PROJECT_DIR" "$target_filter")
  else
    manifests_to_remove+=("$manifest_file")
  fi

  if [[ "${#manifests_to_remove[@]}" -eq 0 ]]; then
    if [[ "${SCOPE:-}" == "local" && "$PROJECT_DIR_EXPLICIT" -eq 0 ]]; then
      die "Para remover instalação local fora do projeto atual, informe --project-dir <dir>."
    fi
    die_with_code "$EXIT_CODE_NOT_FOUND" "$(missing_installation_message "uninstall" "$SCOPE" "$user_scope")"
  fi

  local -a removable_manifests=()
  for manifest_file in "${manifests_to_remove[@]}"; do
    commands_root="$(dirname "$manifest_file")"
    install_dir="${commands_root}/memflow"
    if [[ -d "$install_dir" || -f "$manifest_file" ]]; then
      removable_manifests+=("$manifest_file")
    fi
  done

  if [[ "${#removable_manifests[@]}" -eq 0 ]]; then
    if [[ "${SCOPE:-}" == "local" && "$PROJECT_DIR_EXPLICIT" -eq 0 ]]; then
      die "Para remover instalação local fora do projeto atual, informe --project-dir <dir>."
    fi
    die_with_code "$EXIT_CODE_NOT_FOUND" "$(missing_installation_message "uninstall" "$SCOPE" "$user_scope")"
  fi

  if [[ "${#removable_manifests[@]}" -gt 1 ]]; then
    log_info "Removendo ${#removable_manifests[@]} instalações (global/local)."
  fi

  for manifest_file in "${removable_manifests[@]}"; do
    commands_root="$(dirname "$manifest_file")"
    local target_in_manifest
    target_in_manifest="$(parse_manifest_value "$manifest_file" "target")"
    install_dir="$(install_dir_for_target "$commands_root" "$target_in_manifest")"
    printf "Destino de remoção: %s\n" "$install_dir"
    if [[ "$target_in_manifest" == "vscode" ]]; then
      printf "Destino de remoção: %s\n" "${commands_root}/prompts"
    fi
  done

  if [[ "$NON_INTERACTIVE" -eq 0 ]] && ! confirm_tty "Confirmar remoção completa do MEMFLOW?" "n"; then
    log_warn "Remoção cancelada pelo usuário."
    exit 0
  fi

  local removed_count=0
  for manifest_file in "${removable_manifests[@]}"; do
    commands_root="$(dirname "$manifest_file")"
    local target_in_manifest
    target_in_manifest="$(parse_manifest_value "$manifest_file" "target")"
    install_dir="$(install_dir_for_target "$commands_root" "$target_in_manifest")"
    if [[ "$target_in_manifest" == "vscode" ]]; then
      rm -f "${commands_root}/prompts/memflow."*.prompt.md
      rm -f "${commands_root}/agents/memflow."*.agent.md
    else
      rm -rf "$install_dir"
    fi
    rm -f "$manifest_file"
    removed_count=$((removed_count + 1))
  done

  if [[ "$removed_count" -gt 1 ]]; then
    log_info "MEMFLOW removido com sucesso em ${removed_count} escopo(s)."
  else
    log_info "MEMFLOW removido com sucesso."
  fi
}

run_check() {
  local user_scope="${SCOPE:-}"
  local os_name="${SELECTED_OS:-$(detect_os)}"
  local default_target="$TARGET"
  if [[ -z "$default_target" ]]; then
    default_target="opencode"
  fi
  local target_filter=""
  if [[ "$TARGET_EXPLICIT" -eq 1 ]]; then
    target_filter="$default_target"
  fi
  local manifest_file=""
  local -a manifests_to_check=()
  if [[ -n "$user_scope" ]]; then
    local commands_root
    commands_root="$(commands_root_for_scope "$user_scope" "$default_target" "$os_name" "$PROJECT_DIR")"
    manifest_file="${commands_root}/.memflow-install.json"
    if [[ -f "$manifest_file" ]]; then
      manifests_to_check+=("$manifest_file")
    fi
  else
    while IFS= read -r manifest_file; do
      [[ -n "$manifest_file" ]] && manifests_to_check+=("$manifest_file")
    done < <(collect_existing_manifests "$os_name" "$PROJECT_DIR" "$target_filter")
  fi

  if [[ "${#manifests_to_check[@]}" -eq 0 ]]; then
    return 0
  fi

  local installed_version installed_scope installed_os installed_repo installed_target
  local effective_scope effective_os repo_name latest_version effective_target
  for manifest_file in "${manifests_to_check[@]}"; do
    installed_version="$(parse_manifest_value "$manifest_file" "version")"
    installed_scope="$(parse_manifest_value "$manifest_file" "scope")"
    installed_os="$(parse_manifest_value "$manifest_file" "os")"
    installed_repo="$(parse_manifest_value "$manifest_file" "repo")"
    installed_target="$(parse_manifest_value "$manifest_file" "target")"

    if [[ -z "$installed_version" ]]; then
      continue
    fi

    effective_scope="${installed_scope:-${SCOPE:-global}}"
    effective_os="${installed_os:-$os_name}"
    repo_name="${installed_repo:-$REPO}"
    effective_target="${installed_target:-$default_target}"
    effective_scope="$(normalize_scope_for_target "$effective_scope" "$effective_target")"

    latest_version="$(resolve_latest_version_with_cache "$repo_name" "$effective_os" || true)"
    if [[ -z "$latest_version" ]]; then
      continue
    fi

    if is_version_newer "$latest_version" "$installed_version"; then
      print_version_update_notice "$installed_version" "$latest_version" "$effective_scope" "$effective_os" "$effective_target"
    fi
  done
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
