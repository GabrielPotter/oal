#!/usr/bin/env bash
# Purpose: Start/stop/reset developer environment stacks.
# Inputs:
#   [up|down|reset] (default up)
# Outputs: local foundation and app stacks in docker.
# Examples:
#   bash infra/lifecycle/run/run-dev.sh up
#   bash infra/lifecycle/run/run-dev.sh reset
set -euo pipefail

ACTION="${1:-up}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

case "$ACTION" in
  up)
    bash "$ROOT_DIR/infra/environments/dev/scripts/run/up.sh"
    docker compose -f "$ROOT_DIR/infra/environments/dev/docker/compose/stack.app.yml" up --build -d
    docker compose -f "$ROOT_DIR/infra/environments/dev/docker/compose/stack.app.yml" ps
    ;;
  down)
    docker compose -f "$ROOT_DIR/infra/environments/dev/docker/compose/stack.app.yml" down --remove-orphans
    bash "$ROOT_DIR/infra/environments/dev/scripts/run/down.sh"
    ;;
  reset)
    docker compose -f "$ROOT_DIR/infra/environments/dev/docker/compose/stack.app.yml" down -v --remove-orphans
    bash "$ROOT_DIR/infra/environments/dev/scripts/run/reset.sh"
    ;;
  *)
    echo "Unsupported action: $ACTION"
    exit 2
    ;;
esac
