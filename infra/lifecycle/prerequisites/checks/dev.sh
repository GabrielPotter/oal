#!/usr/bin/env bash
# Purpose: Support script for the infrastructure lifecycle workflow.
# Inputs: see inline logic and calling command arguments/environment variables.
# Outputs/artifacts: command output and exit status used by orchestrator scripts.
# Preconditions: required runtime dependencies must be installed.
# Failure modes + exit codes: returns non-zero on validation/execution failure.
# Examples: run via documented lifecycle entrypoints in infra/README.md.
# Security notes: avoid passing secrets in plain command-line arguments.
# Purpose: Dependency checks specific to local developer workflows.
set -euo pipefail

check_dev_dependencies() {
  local failed=0
  check_or_install_cmd "dotnet" "dotnet-sdk-10.0" "required for .NET service build" || failed=1
  check_or_install_cmd "node" "nodejs" "required for UI build and scripts" || failed=1
  check_or_install_cmd "npm" "npm" "required for UI dependency installation" || failed=1
  check_or_install_cmd "kind" "kind" "required for local Kubernetes-in-Docker development cluster" || failed=1
  check_or_install_cmd "kubectl" "kubectl" "required to manage local kind clusters and validate manifests" || failed=1

  if command -v kustomize >/dev/null 2>&1 || kubectl kustomize --help >/dev/null 2>&1; then
    echo "{\"name\":\"kustomize\",\"status\":\"pass\",\"reason\":\"installed\"}" >> "$REPORT_TMP"
  else
    check_or_install_cmd "kustomize" "kustomize" "required for local overlay rendering with kind-based dev workflow" || failed=1
  fi

  return "$failed"
}
