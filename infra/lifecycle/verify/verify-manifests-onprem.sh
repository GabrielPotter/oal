#!/usr/bin/env bash
# Purpose: Support script for the infrastructure lifecycle workflow.
# Inputs: see inline logic and calling command arguments/environment variables.
# Outputs/artifacts: command output and exit status used by orchestrator scripts.
# Preconditions: required runtime dependencies must be installed.
# Failure modes + exit codes: returns non-zero on validation/execution failure.
# Examples: run via documented lifecycle entrypoints in infra/README.md.
# Security notes: avoid passing secrets in plain command-line arguments.
# Purpose: Validate all on-prem overlays can render with kustomize.
# Examples:
#   bash infra/lifecycle/verify/verify-manifests-onprem.sh
#   KUBECONFIG=~/.kube/config bash infra/lifecycle/verify/verify-manifests-onprem.sh
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
# shellcheck source=/dev/null
source "$ROOT_DIR/infra/lifecycle/deploy/lib/kubernetes.sh"

for env in dev test prod; do
  kustomize_render "$ROOT_DIR/infra/environments/onprem/k8s/overlays/$env" >/dev/null
done

echo "On-prem overlays validated"
