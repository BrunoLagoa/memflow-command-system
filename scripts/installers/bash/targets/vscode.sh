#!/usr/bin/env bash

render_vscode_prompt_with_shared() {
  local src_file="$1"
  local dest_file="$2"
  local source_dir="$3"
  local shared_dir="${source_dir}/_shared"
  local shared_output="${shared_dir}/base-output.md"
  local shared_preconditions="${shared_dir}/base-preconditions.md"
  local shared_degraded="${shared_dir}/base-degraded-mode.md"
  local shared_target_adapter_vscode="${shared_dir}/target-adapter.vscode.md"

  [[ -f "$shared_output" ]] || die "Arquivo compartilhado não encontrado: ${shared_output}"
  [[ -f "$shared_preconditions" ]] || die "Arquivo compartilhado não encontrado: ${shared_preconditions}"
  [[ -f "$shared_degraded" ]] || die "Arquivo compartilhado não encontrado: ${shared_degraded}"
  [[ -f "$shared_target_adapter_vscode" ]] || die "Arquivo compartilhado não encontrado: ${shared_target_adapter_vscode}"

  awk \
    -v shared_output_file="$shared_output" \
    -v shared_preconditions_file="$shared_preconditions" \
    -v shared_degraded_file="$shared_degraded" \
    -v shared_target_adapter_vscode_file="$shared_target_adapter_vscode" '
      function inject_file(path, title,   line) {
        print title
        while ((getline line < path) > 0) {
          print line
        }
        close(path)
      }
      {
        if ($0 ~ /^[[:space:]]*-[[:space:]]+`?_shared\/base-output\.md`?[[:space:]]*$/) {
          inject_file(shared_output_file, "### Conteúdo injetado: _shared/base-output.md")
          next
        }
        if ($0 ~ /^[[:space:]]*-[[:space:]]+`?_shared\/base-preconditions\.md`?[[:space:]]*$/) {
          inject_file(shared_preconditions_file, "### Conteúdo injetado: _shared/base-preconditions.md")
          next
        }
        if ($0 ~ /^[[:space:]]*-[[:space:]]+`?_shared\/base-degraded-mode\.md`?[[:space:]]*$/) {
          inject_file(shared_degraded_file, "### Conteúdo injetado: _shared/base-degraded-mode.md")
          next
        }
        if ($0 ~ /^[[:space:]]*-[[:space:]]+`?_shared\/target-adapter\.md`?[[:space:]]*$/) {
          inject_file(shared_target_adapter_vscode_file, "### Conteúdo injetado: _shared/target-adapter.vscode.md")
          next
        }
        print
      }
    ' "$src_file" > "$dest_file"
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
