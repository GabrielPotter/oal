#!/usr/bin/env bash
# Purpose: Start on-prem bootstrap stack (includes development-mode identity for initial setup).
# Inputs: none
# Outputs: running bootstrap stack.
# Examples:
#   bash infra/environments/onprem/scripts/run/bootstrap-up.sh
#   bash infra/environments/onprem/scripts/run/bootstrap-up.sh
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../.." && pwd)"
docker compose -f "$ROOT_DIR/infra/environments/onprem/docker/compose/stack.bootstrap.yml" up --build -d
docker compose -f "$ROOT_DIR/infra/environments/onprem/docker/compose/stack.bootstrap.yml" ps
