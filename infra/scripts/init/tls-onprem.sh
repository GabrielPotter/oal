#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <domain> <email>"
  echo "Example: $0 app.example.com admin@example.com"
  exit 1
fi

DOMAIN="$1"
EMAIL="$2"

echo "Preparing Let's Encrypt certificate request for domain: $DOMAIN"
echo "Using email: $EMAIL"
echo ""
echo "Recommended first run (staging):"
echo "  certbot certonly --staging --standalone -d $DOMAIN --agree-tos -m $EMAIL --non-interactive"
echo ""
echo "Production run:"
echo "  certbot certonly --standalone -d $DOMAIN --agree-tos -m $EMAIL --non-interactive"
echo ""
echo "Expected cert paths:"
echo "  /etc/letsencrypt/live/$DOMAIN/fullchain.pem"
echo "  /etc/letsencrypt/live/$DOMAIN/privkey.pem"
echo ""
echo "After issuing cert, start HTTPS stack:"
echo "  docker compose -f infra/docker/compose/docker-compose.onprem-https.yml up --build -d"
