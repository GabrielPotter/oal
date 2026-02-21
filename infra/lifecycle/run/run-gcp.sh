#!/usr/bin/env bash
# Purpose: Run non-local GCP smoke checks against deployed edge.
# Inputs:
#   --base-url https://app.example.com
# Examples:
#   bash infra/lifecycle/run/run-gcp.sh --base-url https://app.example.com
#   bash infra/lifecycle/run/run-gcp.sh --base-url https://app-dev.example.com
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
bash "$ROOT_DIR/infra/environments/gcp/scripts/run/smoke-check.sh" "$@"
