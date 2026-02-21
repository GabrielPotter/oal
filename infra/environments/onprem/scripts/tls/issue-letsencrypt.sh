#!/usr/bin/env bash
# Purpose: Guide Let's Encrypt certificate issuance for on-prem HTTPS edge.
# Inputs:
#   <domain> <email>
# Outputs:
#   - printed certbot commands and expected certificate paths.
# Preconditions:
#   - certbot installed and public DNS points to edge host.
# Failure modes:
#   - exits 1 on missing args.
# Examples:
#   bash infra/environments/onprem/scripts/tls/issue-letsencrypt.sh app.example.com admin@example.com
#   bash infra/environments/onprem/scripts/tls/issue-letsencrypt.sh app-prod.example.com ops@example.com
# Security notes:
#   - do not expose private key paths publicly.
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <domain> <email>"
  exit 1
fi

DOMAIN="$1"
EMAIL="$2"

echo "Staging test:"
echo "certbot certonly --staging --standalone -d $DOMAIN --agree-tos -m $EMAIL --non-interactive"
echo
echo "Production issuance:"
echo "certbot certonly --standalone -d $DOMAIN --agree-tos -m $EMAIL --non-interactive"
echo
echo "Expected certs: /etc/letsencrypt/live/$DOMAIN/{fullchain.pem,privkey.pem}"
