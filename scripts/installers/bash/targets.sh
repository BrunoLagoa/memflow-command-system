#!/usr/bin/env bash

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
