#!/usr/bin/env bash

render_command_with_shared_injection() {
  local src_file="$1"
  local dest_file="$2"
  local source_dir="$3"
  local target_adapter_relative_path="$4"
  local target_adapter_injected_title="$5"

  local shared_dir="${source_dir}/_shared"
  local shared_output="${shared_dir}/base-output.md"
  local shared_preconditions="${shared_dir}/base-preconditions.md"
  local shared_degraded="${shared_dir}/base-degraded-mode.md"
  local shared_target_adapter="${shared_dir}/${target_adapter_relative_path}"
  local model_policy_file="${source_dir}/model-policy.md"

  [[ -f "$shared_output" ]] || die "Arquivo compartilhado não encontrado: ${shared_output}"
  [[ -f "$shared_preconditions" ]] || die "Arquivo compartilhado não encontrado: ${shared_preconditions}"
  [[ -f "$shared_degraded" ]] || die "Arquivo compartilhado não encontrado: ${shared_degraded}"
  [[ -f "$shared_target_adapter" ]] || die "Arquivo compartilhado não encontrado: ${shared_target_adapter}"
  [[ -f "$model_policy_file" ]] || die "Arquivo não encontrado: ${model_policy_file}"

  awk \
    -v shared_output_file="$shared_output" \
    -v shared_preconditions_file="$shared_preconditions" \
    -v shared_degraded_file="$shared_degraded" \
    -v shared_target_adapter_file="$shared_target_adapter" \
    -v shared_target_adapter_title="$target_adapter_injected_title" \
    -v model_policy_file="$model_policy_file" '
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
          inject_file(shared_target_adapter_file, shared_target_adapter_title)
          next
        }
        if ($0 ~ /^[[:space:]]*-[[:space:]]+`?model-policy\.md`?[[:space:]]*$/) {
          inject_file(model_policy_file, "### Conteúdo injetado: model-policy.md")
          next
        }
        print
      }
    ' "$src_file" > "$dest_file"
}
