#!/usr/bin/env bash
set -euo pipefail

docker compose -f infra/docker/compose/docker-compose.onprem-https.yml down --remove-orphans
