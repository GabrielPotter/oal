#!/usr/bin/env bash
# Purpose: Start local foundation services for development.
# Inputs: none
# Outputs: running local postgres/redis/rabbitmq/keycloak containers.
# Preconditions: docker compose installed.
# Examples:
#   bash infra/environments/dev/scripts/run/up.sh
#   COMPOSE_PROFILES=default bash infra/environments/dev/scripts/run/up.sh
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../.." && pwd)"
docker compose -f "$ROOT_DIR/infra/environments/dev/docker/compose/stack.foundation.yml" up -d
docker compose -f "$ROOT_DIR/infra/environments/dev/docker/compose/stack.foundation.yml" ps
