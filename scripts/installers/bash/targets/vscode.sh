#!/usr/bin/env bash

render_vscode_prompt_with_shared() {
  local src_file="$1"
  local dest_file="$2"
  local source_dir="$3"

  render_command_with_shared_injection \
    "$src_file" \
    "$dest_file" \
    "$source_dir" \
    "target-adapter.vscode.md" \
    "### Conteúdo injetado: _shared/target-adapter.vscode.md"
}

vscode_install_from_source() {
  local commands_root="$1"
  local manifest_file="$2"
  local version="$3"
  local source_dir="$4"

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
    if [[ "$stem" == "model-policy" ]]; then
      continue
    fi
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
}

vscode_uninstall_installation() {
  local commands_root="$1"
  local manifest_file="$2"
  rm -f "${commands_root}/prompts/memflow."*.prompt.md
  rm -f "${commands_root}/agents/memflow."*.agent.md
  rm -f "$manifest_file"
}
