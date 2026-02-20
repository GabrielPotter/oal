#!/usr/bin/env bash
set -euo pipefail

docker compose -f infra/docker/compose/docker-compose.dev.yml up --build -d
docker compose -f infra/docker/compose/docker-compose.dev.yml ps
