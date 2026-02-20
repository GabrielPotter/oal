#!/usr/bin/env bash
set -euo pipefail

echo "Resetting local environment..."
docker compose -f infra/docker/compose/docker-compose.local.yml down -v --remove-orphans
docker compose -f infra/docker/compose/docker-compose.local.yml up -d
