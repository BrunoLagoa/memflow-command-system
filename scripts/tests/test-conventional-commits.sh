#!/usr/bin/env bash
set -euo pipefail

CONVENTIONAL_PATTERN='^(feat|fix|docs|style|refactor|perf|test|chore|build|ci)(\([a-z0-9][a-z0-9._/-]*(,[a-z0-9][a-z0-9._/-]*)*\))?(!)?: .+'

resolve_commit_range() {
  if [[ -n "${GITHUB_BASE_REF:-}" ]]; then
    git fetch --no-tags --depth=200 origin "${GITHUB_BASE_REF}"
    printf 'origin/%s..HEAD' "${GITHUB_BASE_REF}"
    return
  fi

  if [[ -n "${GITHUB_EVENT_BEFORE:-}" && "${GITHUB_EVENT_BEFORE}" != "0000000000000000000000000000000000000000" ]]; then
    printf '%s..HEAD' "${GITHUB_EVENT_BEFORE}"
    return
  fi

  printf 'HEAD~1..HEAD'
}

main() {
  local range
  range="$(resolve_commit_range)"

  local commits=()
  while IFS= read -r sha; do
    commits+=("${sha}")
  done < <(git rev-list --no-merges "${range}")

  if [[ "${#commits[@]}" -eq 0 ]]; then
    echo "Nenhum commit para validar no range: ${range}"
    exit 0
  fi

  local has_errors=0

  for sha in "${commits[@]}"; do
    local subject
    subject="$(git log -n 1 --format=%s "${sha}")"

    if [[ ! "${subject}" =~ ${CONVENTIONAL_PATTERN} ]]; then
      echo "Commit fora do padrão Conventional Commits:"
      echo "- SHA: ${sha}"
      echo "- Subject: ${subject}"
      has_errors=1
    fi
  done

  if [[ "${has_errors}" -ne 0 ]]; then
    echo
    echo "Formato esperado:"
    echo "  <tipo>(<escopo opcional>): <descrição>"
    echo
    echo "Tipos permitidos neste projeto:"
    echo "  feat, fix, docs, style, refactor, perf, test, chore, build, ci"
    echo
    echo "Exemplos válidos:"
    echo "  feat(plan): add same-level model alternatives"
    echo "  fix(installer): handle missing manifest on update"
    echo "  docs(readme): document commit convention"
    exit 1
  fi

  echo "Todos os commits seguem Conventional Commits no range: ${range}"
}

main "$@"
