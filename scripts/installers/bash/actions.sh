#!/usr/bin/env bash

dispatch_install_for_target() {
  local target="$1"
  local commands_root="$2"
  local install_dir="$3"
  local manifest_file="$4"
  local version="$5"
  local source_dir="$6"

  case "$target" in
    opencode)
      opencode_install_from_source "$commands_root" "$install_dir" "$manifest_file" "$version" "$source_dir"
      ;;
    vscode)
      vscode_install_from_source "$commands_root" "$manifest_file" "$version" "$source_dir"
      ;;
    *)
      die "Target não suportado para instalação: $target"
      ;;
  esac
}

dispatch_uninstall_for_target() {
  local target="$1"
  local commands_root="$2"
  local install_dir="$3"
  local manifest_file="$4"

  case "$target" in
    opencode)
      opencode_uninstall_installation "$install_dir" "$manifest_file"
      ;;
    vscode)
      vscode_uninstall_installation "$commands_root" "$manifest_file"
      ;;
    *)
      die "Target não suportado para remoção: $target"
      ;;
  esac
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

perform_install() {
  local commands_root="$1"
  local install_dir="$2"
  local manifest_file="$3"
  local version="$4"
  local source_dir
  source_dir="$(resolve_source_dir "$version")"
  dispatch_install_for_target "$TARGET" "$commands_root" "$install_dir" "$manifest_file" "$version" "$source_dir"
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
    local target_in_manifest
    if [[ -f "$manifest_file" ]]; then
      target_in_manifest="$(parse_manifest_value "$manifest_file" "target")"
    else
      target_in_manifest=""
    fi
    if [[ -z "$target_in_manifest" ]]; then
      target_in_manifest="${TARGET:-opencode}"
    fi
    install_dir="$(install_dir_for_target "$commands_root" "$target_in_manifest")"
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
    if [[ -f "$manifest_file" ]]; then
      target_in_manifest="$(parse_manifest_value "$manifest_file" "target")"
    else
      target_in_manifest=""
    fi
    if [[ -z "$target_in_manifest" ]]; then
      target_in_manifest="${TARGET:-opencode}"
    fi
    install_dir="$(install_dir_for_target "$commands_root" "$target_in_manifest")"
    printf "Destino de remoção: %s\n" "$install_dir"
  done

  if [[ "$NON_INTERACTIVE" -eq 0 ]] && ! confirm_tty "Confirmar remoção completa do MEMFLOW?" "n"; then
    log_warn "Remoção cancelada pelo usuário."
    exit 0
  fi

  local removed_count=0
  for manifest_file in "${removable_manifests[@]}"; do
    commands_root="$(dirname "$manifest_file")"
    local target_in_manifest
    if [[ -f "$manifest_file" ]]; then
      target_in_manifest="$(parse_manifest_value "$manifest_file" "target")"
    else
      target_in_manifest=""
    fi
    if [[ -z "$target_in_manifest" ]]; then
      target_in_manifest="${TARGET:-opencode}"
    fi
    install_dir="$(install_dir_for_target "$commands_root" "$target_in_manifest")"
    dispatch_uninstall_for_target "$target_in_manifest" "$commands_root" "$install_dir" "$manifest_file"
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
