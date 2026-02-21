#!/usr/bin/env bash
# Purpose: Validate deployed GCP edge endpoints after deployment.
# Inputs:
#   --base-url https://app.example.com
# Outputs:
#   - exit 0 when /health/live and /version respond successfully.
# Examples:
#   bash infra/environments/gcp/scripts/run/smoke-check.sh --base-url https://app.example.com
#   bash infra/environments/gcp/scripts/run/smoke-check.sh --base-url https://app-dev.example.com
set -euo pipefail

BASE_URL=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --base-url) BASE_URL="$2"; shift 2 ;;
    *) echo "Unknown argument: $1"; exit 2 ;;
  esac
done

if [[ -z "$BASE_URL" ]]; then
  echo "Missing --base-url"
  exit 2
fi

curl -fsS "$BASE_URL/api/health/live" >/dev/null
curl -fsS "$BASE_URL/api/version" >/dev/null
echo "GCP smoke-check passed for $BASE_URL"
