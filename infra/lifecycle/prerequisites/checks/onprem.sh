#!/usr/bin/env bash
# Purpose: Support script for the infrastructure lifecycle workflow.
# Inputs: see inline logic and calling command arguments/environment variables.
# Outputs/artifacts: command output and exit status used by orchestrator scripts.
# Preconditions: required runtime dependencies must be installed.
# Failure modes + exit codes: returns non-zero on validation/execution failure.
# Examples: run via documented lifecycle entrypoints in infra/README.md.
# Security notes: avoid passing secrets in plain command-line arguments.
# Purpose: Dependency checks for on-prem production operations.
set -euo pipefail

check_onprem_dependencies() {
  local failed=0
  check_or_install_cmd "openssl" "openssl" "required for TLS validation" || failed=1
  check_or_install_cmd "certbot" "certbot" "required for Let's Encrypt certificate lifecycle" || failed=1
  check_or_install_cmd "nginx" "nginx" "required for edge reverse-proxy in VM deployment mode" || failed=1
  check_or_install_cmd "kubectl" "kubectl" "required for on-prem Kubernetes deployment workflow" || failed=1

  if command -v kustomize >/dev/null 2>&1 || kubectl kustomize --help >/dev/null 2>&1; then
    echo "{\"name\":\"kustomize\",\"status\":\"pass\",\"reason\":\"installed\"}" >> "$REPORT_TMP"
  else
    check_or_install_cmd "kustomize" "kustomize" "required for on-prem overlay rendering and deployment" || failed=1
  fi

  return "$failed"
}
