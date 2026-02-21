#!/usr/bin/env bash
# Purpose: Support script for the infrastructure lifecycle workflow.
# Inputs: see inline logic and calling command arguments/environment variables.
# Outputs/artifacts: command output and exit status used by orchestrator scripts.
# Preconditions: required runtime dependencies must be installed.
# Failure modes + exit codes: returns non-zero on validation/execution failure.
# Examples: run via documented lifecycle entrypoints in infra/README.md.
# Security notes: avoid passing secrets in plain command-line arguments.
# Purpose: kustomize/kubectl helper wrappers used by deploy/verify scripts.
set -euo pipefail

kustomize_render() {
  local overlay="$1"
  if command -v kubectl >/dev/null 2>&1; then
    kubectl kustomize "$overlay"
    return
  fi

  if command -v kustomize >/dev/null 2>&1; then
    kustomize build "$overlay"
    return
  fi

  echo "Missing kubectl or kustomize"
  return 1
}

kustomize_apply() {
  local overlay="$1"
  kustomize_render "$overlay" | kubectl apply -f -
}
