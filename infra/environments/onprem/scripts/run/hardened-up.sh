#!/usr/bin/env bash
# Purpose: Start hardened on-prem production stack.
# Inputs:
#   --env-file <path> (optional; defaults to .env)
# Outputs:
#   - running hardened stack.
# Examples:
#   bash infra/environments/onprem/scripts/run/hardened-up.sh
#   bash infra/environments/onprem/scripts/run/hardened-up.sh --env-file infra/environments/onprem/config/env.example
# Security notes:
#   - env file should be stored securely and not committed with real secrets.
set -euo pipefail

ENV_FILE=".env"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --env-file) ENV_FILE="$2"; shift 2 ;;
    *) echo "Unknown argument: $1"; exit 2 ;;
  esac
done

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../.." && pwd)"
docker compose --env-file "$ROOT_DIR/$ENV_FILE" -f "$ROOT_DIR/infra/environments/onprem/docker/compose/stack.hardened.yml" up --build -d
docker compose --env-file "$ROOT_DIR/$ENV_FILE" -f "$ROOT_DIR/infra/environments/onprem/docker/compose/stack.hardened.yml" ps
