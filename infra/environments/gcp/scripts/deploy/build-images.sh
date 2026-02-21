#!/usr/bin/env bash
# Purpose: Support script for the infrastructure lifecycle workflow.
# Inputs: see inline logic and calling command arguments/environment variables.
# Outputs/artifacts: command output and exit status used by orchestrator scripts.
# Preconditions: required runtime dependencies must be installed.
# Failure modes + exit codes: returns non-zero on validation/execution failure.
# Examples: run via documented lifecycle entrypoints in infra/README.md.
# Security notes: avoid passing secrets in plain command-line arguments.
# Purpose: Build all images for GCP deployment using lifecycle build pipeline.
# Examples:
#   REGISTRY_PREFIX=us-central1-docker.pkg.dev/my-project/oal bash infra/environments/gcp/scripts/deploy/build-images.sh
#   IMAGE_TAG=v1 REGISTRY_PREFIX=us-central1-docker.pkg.dev/my-project/oal bash infra/environments/gcp/scripts/deploy/build-images.sh
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../.." && pwd)"
cd "$ROOT_DIR"
bash infra/lifecycle/build/build-images.sh
