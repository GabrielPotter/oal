#!/usr/bin/env bash
# Purpose: Support script for the infrastructure lifecycle workflow.
# Inputs: see inline logic and calling command arguments/environment variables.
# Outputs/artifacts: command output and exit status used by orchestrator scripts.
# Preconditions: required runtime dependencies must be installed.
# Failure modes + exit codes: returns non-zero on validation/execution failure.
# Examples: run via documented lifecycle entrypoints in infra/README.md.
# Security notes: avoid passing secrets in plain command-line arguments.
# Purpose: registry helper functions for build/push steps.
set -euo pipefail

require_registry_prefix() {
  if [[ -z "${REGISTRY_PREFIX:-}" ]]; then
    echo "Missing REGISTRY_PREFIX. Example: us-central1-docker.pkg.dev/my-project/oal"
    return 1
  fi
}

image_ref() {
  local image_name="$1"
  local tag="$2"
  echo "${REGISTRY_PREFIX}/${image_name}:${tag}"
}
