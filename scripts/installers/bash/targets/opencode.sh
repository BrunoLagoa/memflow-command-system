#!/usr/bin/env bash

opencode_install_from_source() {
  local commands_root="$1"
  local install_dir="$2"
  local manifest_file="$3"
  local version="$4"
  local source_dir="$5"

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

opencode_uninstall_installation() {
  local install_dir="$1"
  local manifest_file="$2"
  rm -rf "$install_dir"
  rm -f "$manifest_file"
}
