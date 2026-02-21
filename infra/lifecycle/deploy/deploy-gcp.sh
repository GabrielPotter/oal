#!/usr/bin/env bash
# Purpose: Full GCP deployment pipeline (build, push, terraform, kustomize apply).
# Inputs:
#   --env {dev|test|prod}
#   REGISTRY_PREFIX (required env)
# Outputs:
#   - pushed images
#   - provisioned/updated infra
#   - applied workload manifests
# Preconditions:
#   - gcloud authenticated, kubectl context set, terraform configured.
# Failure modes:
#   - exits non-zero on any pipeline stage failure.
# Examples:
#   REGISTRY_PREFIX=us-central1-docker.pkg.dev/p/oal bash infra/lifecycle/deploy/deploy-gcp.sh --env dev
#   REGISTRY_PREFIX=us-central1-docker.pkg.dev/p/oal IMAGE_TAG=v1 bash infra/lifecycle/deploy/deploy-gcp.sh --env prod
# Security notes:
#   - use workload identity/service account auth instead of static keys where possible.
set -euo pipefail

ENV_NAME=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --env) ENV_NAME="$2"; shift 2 ;;
    *) echo "Unknown argument: $1"; exit 2 ;;
  esac
done

if [[ -z "$ENV_NAME" ]]; then
  echo "Missing --env"
  exit 2
fi

if [[ -z "${REGISTRY_PREFIX:-}" ]]; then
  echo "Missing REGISTRY_PREFIX"
  exit 2
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$ROOT_DIR"

bash infra/lifecycle/build/build-all.sh --target gcp --env "$ENV_NAME"
bash infra/environments/gcp/scripts/deploy/push-images.sh
bash infra/environments/gcp/scripts/deploy/terraform-apply.sh --env "$ENV_NAME"
bash infra/environments/gcp/scripts/deploy/kustomize-apply.sh --env "$ENV_NAME"

MANIFEST_DIR="$ROOT_DIR/infra/lifecycle/build/out/release"
mkdir -p "$MANIFEST_DIR"
MANIFEST_PATH="$MANIFEST_DIR/manifest.json"
COMMIT_SHA="$(git -C "$ROOT_DIR" rev-parse HEAD)"
DEPLOY_TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
IMAGE_TAG_VALUE="${IMAGE_TAG:-$(git -C "$ROOT_DIR" rev-parse --short=12 HEAD)}"
IMAGES_JSON="$(jq -nc \
  --arg registry "$REGISTRY_PREFIX" \
  --arg tag "$IMAGE_TAG_VALUE" \
  '[\"gateway-api\",\"identity-api\",\"catalog-api\",\"web-nginx\"] | map({path:(($registry + \"/\" + . + \":\" + $tag)), sha256:\"pending\"})')"
cat > "$MANIFEST_PATH" <<JSON
{
  "target": "gcp",
  "environment": "$ENV_NAME",
  "commit": "$COMMIT_SHA",
  "deploymentTimestampUtc": "$DEPLOY_TS",
  "imageTag": "$IMAGE_TAG_VALUE",
  "checksums": $IMAGES_JSON
}
JSON
echo "Release manifest generated: $MANIFEST_PATH"
