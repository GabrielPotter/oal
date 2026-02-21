#!/usr/bin/env bash
# Purpose: Support script for the infrastructure lifecycle workflow.
# Inputs: see inline logic and calling command arguments/environment variables.
# Outputs/artifacts: command output and exit status used by orchestrator scripts.
# Preconditions: required runtime dependencies must be installed.
# Failure modes + exit codes: returns non-zero on validation/execution failure.
# Examples: run via documented lifecycle entrypoints in infra/README.md.
# Security notes: avoid passing secrets in plain command-line arguments.
# Purpose: Dependency checks for Google Cloud deployment operations.
set -euo pipefail

check_gcp_dependencies() {
  local failed=0
  check_or_install_cmd "gcloud" "google-cloud-cli" "required for GCP auth and registry operations" || failed=1
  check_or_install_cmd "kubectl" "kubectl" "required for k8s apply and cluster access" || failed=1
  check_or_install_cmd "terraform" "terraform" "required for infrastructure provisioning" || failed=1

  if command -v kustomize >/dev/null 2>&1 || kubectl kustomize --help >/dev/null 2>&1; then
    echo "{\"name\":\"kustomize\",\"status\":\"pass\",\"reason\":\"installed\"}" >> "$REPORT_TMP"
  else
    check_or_install_cmd "kustomize" "kustomize" "required to build overlays" || failed=1
  fi

  return "$failed"
}
