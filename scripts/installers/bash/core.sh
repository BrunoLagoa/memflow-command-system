#!/usr/bin/env bash

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
  if command -v python3 >/dev/null 2>&1; then
    python3 - "$file" "$key" <<'PY'
import json
import sys

path = sys.argv[1]
key = sys.argv[2]
try:
    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f)
    value = data.get(key, "")
    if isinstance(value, str):
        print(value)
except Exception:
    pass
PY
    return 0
  fi
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
  parse_manifest_value "$file" "$key"
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
  local update_command="curl -fsSL https://raw.githubusercontent.com/${REPO}/main/scripts/install.sh | bash -s -- update --scope ${scope_value} --non-interactive"
  if [[ "$target_value" == "vscode" ]]; then
    update_command="curl -fsSL https://raw.githubusercontent.com/${REPO}/main/scripts/install.sh | bash -s -- update --target vscode --project-dir . --non-interactive"
  elif [[ "$os_name" == "windows" ]]; then
    update_command="powershell -ExecutionPolicy Bypass -Command \"iwr https://raw.githubusercontent.com/${REPO}/main/scripts/install.ps1 -OutFile \$env:TEMP\\install.ps1; & \$env:TEMP\\install.ps1 update -Scope ${scope_value} -NonInteractive\""
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
