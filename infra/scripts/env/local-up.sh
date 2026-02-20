#!/usr/bin/env bash
set -euo pipefail

echo "Starting local environment..."
docker compose -f infra/docker/compose/docker-compose.local.yml up -d
docker compose -f infra/docker/compose/docker-compose.local.yml ps
