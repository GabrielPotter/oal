#!/usr/bin/env bash
# Purpose: Push lifecycle-built images to target container registry.
# Inputs:
#   - REGISTRY_PREFIX (required)
#   - IMAGE_TAG (optional; defaults to git short sha)
# Examples:
#   REGISTRY_PREFIX=us-central1-docker.pkg.dev/my-project/oal bash infra/environments/gcp/scripts/deploy/push-images.sh
#   REGISTRY_PREFIX=us-central1-docker.pkg.dev/my-project/oal IMAGE_TAG=v1 bash infra/environments/gcp/scripts/deploy/push-images.sh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../.." && pwd)"
# shellcheck source=/dev/null
source "$ROOT_DIR/infra/lifecycle/deploy/lib/tags.sh"

REGISTRY_PREFIX="${REGISTRY_PREFIX:-}"
if [[ -z "$REGISTRY_PREFIX" ]]; then
  echo "REGISTRY_PREFIX is required"
  exit 2
fi

TAG="$(resolve_image_tag)"
for image in gateway-api identity-api catalog-api web-nginx; do
  ref="${REGISTRY_PREFIX}/${image}:${TAG}"
  docker push "$ref"
done
