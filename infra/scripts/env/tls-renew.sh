#!/usr/bin/env bash
set -euo pipefail

echo "Renewing Let's Encrypt certificates..."
certbot renew --quiet

echo "Reloading nginx in on-prem HTTPS stack..."
docker compose -f infra/docker/compose/docker-compose.onprem-https.yml exec web-nginx nginx -s reload

echo "TLS renewal complete."
