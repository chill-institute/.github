#!/usr/bin/env bash
set -euo pipefail

out() { printf '%s=%s\n' "$1" "$2" >>"$GITHUB_OUTPUT"; }

case "$GITLEAKS" in
  auto | true | false) ;;
  *)
    echo "scan: gitleaks must be auto, true, or false" >&2
    exit 1
    ;;
esac

case "$EVENT" in
  push | workflow_dispatch) ;;
  *)
    echo "scan: nothing to do on $EVENT"
    out gitleaks false
    out workflows false
    exit 0
    ;;
esac

if [ "${RUNNER_OS:-Linux}" != Linux ]; then
  echo "scan: Linux runners only" >&2
  exit 1
fi

git_auth() {
  local basic
  basic="$(printf 'x-access-token:%s' "$TOKEN" | base64 | tr -d '\n')"
  git -c "http.https://github.com/.extraheader=AUTHORIZATION: basic $basic" "$@"
}

shallow() { [ "$(git rev-parse --is-shallow-repository)" = true ]; }

head="$(git rev-parse HEAD)"
range=""
if [ "$EVENT" = push ] && [[ "$BEFORE" =~ ^[0-9a-f]{40}$ ]] && [[ ! "$BEFORE" =~ ^0+$ ]]; then
  for _ in 1 2 3 4 5; do
    if git merge-base --is-ancestor "$BEFORE" "$head" 2>/dev/null; then
      range="$BEFORE..$head"
      break
    fi
    shallow || break
    git_auth fetch --quiet --no-tags --deepen=100 origin "$head"
  done
fi

if [ -z "$range" ] && shallow; then
  git_auth fetch --quiet --no-tags --unshallow origin "$head"
fi

if [ "$GITLEAKS" = true ] || { [ "$GITLEAKS" = auto ] && [ "$PRIVATE" = true ]; }; then
  out gitleaks true
else
  out gitleaks false
fi

if [ -z "$range" ]; then
  echo "scan: full history"
  out log-opts "$head"
  out workflows true
  exit 0
fi

echo "scan: $range"
out log-opts "$range"
changed="$(git diff --name-only --no-renames "$range")"
if grep -Eq '^\.github/|(^|/)action\.ya?ml$|(^|/)\.?zizmor\.ya?ml$|(^|/)\.shellcheckrc$' <<<"$changed"; then
  out workflows true
else
  out workflows false
fi
