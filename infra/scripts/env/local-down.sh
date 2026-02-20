#!/usr/bin/env bash
set -euo pipefail

echo "Stopping local environment..."
docker compose -f infra/docker/compose/docker-compose.local.yml down --remove-orphans
