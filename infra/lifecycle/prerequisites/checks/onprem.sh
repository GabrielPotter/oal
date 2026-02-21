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
  # On-prem is template-profile driven; cluster/network/cert providers are deployment specific.
  check_or_install_cmd "kubectl" "kubectl" "required for on-prem Kubernetes deployment workflow" || failed=1

  if command -v kustomize >/dev/null 2>&1 || kubectl kustomize --help >/dev/null 2>&1; then
    echo "{\"name\":\"kustomize\",\"status\":\"pass\",\"reason\":\"installed\"}" >> "$REPORT_TMP"
  else
    check_or_install_cmd "kustomize" "kustomize" "required for on-prem overlay rendering and deployment" || failed=1
  fi

  if command -v openssl >/dev/null 2>&1; then
    echo "{\"name\":\"openssl\",\"status\":\"pass\",\"reason\":\"installed\"}" >> "$REPORT_TMP"
  else
    echo "{\"name\":\"openssl\",\"status\":\"warn\",\"reason\":\"optional; required only for local certificate workflows\"}" >> "$REPORT_TMP"
  fi

  if command -v certbot >/dev/null 2>&1; then
    echo "{\"name\":\"certbot\",\"status\":\"pass\",\"reason\":\"installed\"}" >> "$REPORT_TMP"
  else
    echo "{\"name\":\"certbot\",\"status\":\"warn\",\"reason\":\"optional; required only for Let's Encrypt workflows\"}" >> "$REPORT_TMP"
  fi

  if command -v nginx >/dev/null 2>&1; then
    echo "{\"name\":\"nginx\",\"status\":\"pass\",\"reason\":\"installed\"}" >> "$REPORT_TMP"
  else
    echo "{\"name\":\"nginx\",\"status\":\"warn\",\"reason\":\"optional; depends on edge topology\"}" >> "$REPORT_TMP"
  fi

  return "$failed"
}
