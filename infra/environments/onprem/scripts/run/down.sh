#!/usr/bin/env bash
# Purpose: Stop on-prem stacks (bootstrap and hardened) safely.
# Inputs: none
# Outputs: stopped compose stacks.
# Examples:
#   bash infra/environments/onprem/scripts/run/down.sh
#   bash infra/environments/onprem/scripts/run/down.sh
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../.." && pwd)"
docker compose -f "$ROOT_DIR/infra/environments/onprem/docker/compose/stack.bootstrap.yml" down --remove-orphans || true
if [[ -f "$ROOT_DIR/.env" ]]; then
  docker compose --env-file "$ROOT_DIR/.env" -f "$ROOT_DIR/infra/environments/onprem/docker/compose/stack.hardened.yml" down --remove-orphans || true
fi
