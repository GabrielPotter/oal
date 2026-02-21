#!/usr/bin/env bash
# Purpose: Start/stop on-prem template profile in bootstrap or hardened mode.
# Inputs:
#   [bootstrap|hardened|down] (default hardened)
#   --env-file <path> for hardened mode (default .env)
# Notes:
#   - This is an adaptation baseline. Concrete on-prem cluster/cert/edge specifics are deployment-dependent.
# Examples:
#   bash infra/lifecycle/run/run-onprem.sh bootstrap
#   bash infra/lifecycle/run/run-onprem.sh hardened --env-file .env
set -euo pipefail

MODE="${1:-hardened}"
shift || true
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

case "$MODE" in
  bootstrap)
    bash "$ROOT_DIR/infra/environments/onprem/scripts/run/bootstrap-up.sh" "$@"
    ;;
  hardened)
    bash "$ROOT_DIR/infra/environments/onprem/scripts/run/hardened-up.sh" "$@"
    ;;
  down)
    bash "$ROOT_DIR/infra/environments/onprem/scripts/run/down.sh"
    ;;
  *)
    echo "Unsupported mode: $MODE"
    exit 2
    ;;
esac
