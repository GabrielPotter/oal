#!/usr/bin/env bash
# Purpose: Renew on-prem Let's Encrypt certificates and reload edge nginx.
# Inputs: none
# Outputs: renewed certs and nginx reload in running bootstrap/hardened stack.
# Examples:
#   bash infra/environments/onprem/scripts/tls/renew.sh
#   CERTBOT_EMAIL=ops@example.com bash infra/environments/onprem/scripts/tls/renew.sh
# Security notes:
#   - certificate private keys remain in /etc/letsencrypt.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../.." && pwd)"
certbot renew --quiet
docker compose -f "$ROOT_DIR/infra/environments/onprem/docker/compose/stack.bootstrap.yml" exec web-nginx nginx -s reload
