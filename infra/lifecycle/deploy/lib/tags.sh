#!/usr/bin/env bash
# Purpose: Support script for the infrastructure lifecycle workflow.
# Inputs: see inline logic and calling command arguments/environment variables.
# Outputs/artifacts: command output and exit status used by orchestrator scripts.
# Preconditions: required runtime dependencies must be installed.
# Failure modes + exit codes: returns non-zero on validation/execution failure.
# Examples: run via documented lifecycle entrypoints in infra/README.md.
# Security notes: avoid passing secrets in plain command-line arguments.
# Purpose: image tagging helpers for deterministic build/deploy metadata.
set -euo pipefail

get_git_sha_short() {
  git rev-parse --short=12 HEAD
}

resolve_image_tag() {
  local explicit_tag="${IMAGE_TAG:-}"
  if [[ -n "$explicit_tag" ]]; then
    echo "$explicit_tag"
    return
  fi

  get_git_sha_short
}
