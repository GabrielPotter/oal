#!/usr/bin/env bash
set -euo pipefail

bash infra/scripts/verify/verify-dotnet.sh
bash infra/scripts/verify/verify-ui.sh
docker compose -f infra/docker/compose/docker-compose.dev.yml config >/dev/null
docker compose -f infra/docker/compose/docker-compose.onprem-https.yml config >/dev/null
