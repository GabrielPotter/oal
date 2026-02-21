#!/usr/bin/env bash
# Purpose: Verify deployment runtime contract endpoints.
# Inputs:
#   --base-url <url>
# Outputs:
#   - exit 0 when /health/live, /health/ready and /version are healthy.
# Examples:
#   bash infra/lifecycle/verify/verify-deploy-contract.sh --base-url http://localhost:8080
#   bash infra/lifecycle/verify/verify-deploy-contract.sh --base-url https://app.example.com/api
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

curl -fsS "$BASE_URL/health/live" >/dev/null
curl -fsS "$BASE_URL/health/ready" >/dev/null
curl -fsS "$BASE_URL/version" >/dev/null

echo "Deploy contract checks passed for $BASE_URL"
