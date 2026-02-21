#!/usr/bin/env bash
# Purpose: Support script for the infrastructure lifecycle workflow.
# Inputs: see inline logic and calling command arguments/environment variables.
# Outputs/artifacts: command output and exit status used by orchestrator scripts.
# Preconditions: required runtime dependencies must be installed.
# Failure modes + exit codes: returns non-zero on validation/execution failure.
# Examples: run via documented lifecycle entrypoints in infra/README.md.
# Security notes: avoid passing secrets in plain command-line arguments.
# Purpose: Print recommended install commands for GCP deployment tooling.
# Outputs: human-readable install command hints.
# Examples:
#   bash infra/environments/gcp/prerequisites/tools.sh
#   bash infra/environments/gcp/prerequisites/tools.sh
set -euo pipefail

echo "Recommended tooling install references:"
echo "- gcloud CLI: https://cloud.google.com/sdk/docs/install"
echo "- kubectl: https://kubernetes.io/docs/tasks/tools/"
echo "- kustomize: https://kubectl.docs.kubernetes.io/installation/kustomize/"
echo "- terraform: https://developer.hashicorp.com/terraform/downloads"
