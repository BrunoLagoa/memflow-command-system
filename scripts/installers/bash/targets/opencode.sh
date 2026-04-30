#!/usr/bin/env bash

render_opencode_command_with_shared() {
  local src_file="$1"
  local dest_file="$2"
  local source_dir="$3"

  render_command_with_shared_injection \
    "$src_file" \
    "$dest_file" \
    "$source_dir" \
    "target-adapter.md" \
    "### Conteúdo injetado: _shared/target-adapter.md"
}

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

  local src_file stem dest_file generated_count
  mkdir -p "$install_dir"

  generated_count=0
  shopt -s nullglob
  for src_file in "${source_dir}"/*.md; do
    stem="$(basename "$src_file" .md)"
    if [[ "$stem" == "model-policy" ]]; then
      continue
    fi
    dest_file="${install_dir}/${stem}.md"
    render_opencode_command_with_shared "$src_file" "$dest_file" "$source_dir"
    generated_count=$((generated_count + 1))
  done
  shopt -u nullglob

  if [[ "$generated_count" -eq 0 ]]; then
    die "Nenhum comando encontrado em ${source_dir} para instalação OpenCode."
  fi

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
