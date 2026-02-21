#!/usr/bin/env bash
# Purpose: Full on-prem deployment pipeline (build, package, optional copy, apply).
# Inputs:
#   --env {dev|test|prod}
#   --mode {compose-hardened|k8s}
#   --env-file <path> (default .env)
#   --remote <user@host> (optional)
# Outputs:
#   - release bundle at infra/lifecycle/build/out/release/*.tar.gz
#   - deployed stack on target host/cluster.
# Preconditions:
#   - prerequisites satisfied for onprem target.
# Failure modes:
#   - exits non-zero on build/package/deploy failures.
# Examples:
#   bash infra/lifecycle/deploy/deploy-onprem.sh --env prod --mode compose-hardened --env-file .env
#   bash infra/lifecycle/deploy/deploy-onprem.sh --env prod --mode k8s --remote ops@onprem-host
# Security notes:
#   - avoid committing env files with secrets.
set -euo pipefail

ENV_NAME=""
MODE="compose-hardened"
ENV_FILE=".env"
REMOTE_HOST=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --env) ENV_NAME="$2"; shift 2 ;;
    --mode) MODE="$2"; shift 2 ;;
    --env-file) ENV_FILE="$2"; shift 2 ;;
    --remote) REMOTE_HOST="$2"; shift 2 ;;
    *) echo "Unknown argument: $1"; exit 2 ;;
  esac
done

if [[ -z "$ENV_NAME" ]]; then
  echo "Missing --env"
  exit 2
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$ROOT_DIR"

bash infra/lifecycle/build/build-all.sh --target onprem --env "$ENV_NAME"

BUNDLE_DIR="$ROOT_DIR/infra/lifecycle/build/out/release"
mkdir -p "$BUNDLE_DIR"
BUNDLE_PATH="$BUNDLE_DIR/onprem-${ENV_NAME}-$(date +%Y%m%d%H%M%S).tar.gz"
MANIFEST_PATH="$BUNDLE_DIR/manifest.json"

tar -czf "$BUNDLE_PATH" \
  infra/environments/onprem/docker/compose \
  infra/environments/onprem/k8s/overlays/"$ENV_NAME" \
  infra/environments/onprem/manifests \
  infra/environments/onprem/edge/nginx \
  "$ENV_FILE"

echo "Created release bundle: $BUNDLE_PATH"
BUNDLE_SHA256="$(sha256sum "$BUNDLE_PATH" | awk '{print $1}')"
COMMIT_SHA="$(git -C "$ROOT_DIR" rev-parse HEAD)"
DEPLOY_TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
IMAGE_TAG_VALUE="${IMAGE_TAG:-$(git -C "$ROOT_DIR" rev-parse --short=12 HEAD)}"
cat > "$MANIFEST_PATH" <<JSON
{
  "target": "onprem",
  "environment": "$ENV_NAME",
  "commit": "$COMMIT_SHA",
  "deploymentTimestampUtc": "$DEPLOY_TS",
  "imageTag": "$IMAGE_TAG_VALUE",
  "bundlePath": "${BUNDLE_PATH#$ROOT_DIR/}",
  "checksums": [
    {
      "path": "${BUNDLE_PATH#$ROOT_DIR/}",
      "sha256": "$BUNDLE_SHA256"
    }
  ]
}
JSON
echo "Release manifest generated: $MANIFEST_PATH"

if [[ -n "$REMOTE_HOST" ]]; then
  scp "$BUNDLE_PATH" "$REMOTE_HOST:~/"
  echo "Bundle copied to $REMOTE_HOST"
fi

case "$MODE" in
  compose-hardened)
    bash infra/environments/onprem/scripts/run/hardened-up.sh --env-file "$ENV_FILE"
    ;;
  k8s)
    kubectl apply -k "infra/environments/onprem/k8s/overlays/$ENV_NAME"
    ;;
  *)
    echo "Unsupported mode: $MODE"
    exit 2
    ;;
esac
