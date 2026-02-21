#!/usr/bin/env bash
# Purpose: Build all deployable container images with deterministic tags.
# Inputs:
#   - REGISTRY_PREFIX (optional; default local/oal)
#   - IMAGE_TAG (optional; default git sha short)
# Outputs:
#   - local container images
#   - infra/lifecycle/build/out/build-metadata.json
# Preconditions: docker daemon available.
# Failure modes: exits non-zero on docker build failure.
# Examples:
#   bash infra/lifecycle/build/build-images.sh
#   REGISTRY_PREFIX=us-central1-docker.pkg.dev/p/oal IMAGE_TAG=v1 bash infra/lifecycle/build/build-images.sh
# Security notes: avoid passing registry credentials in plain args.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
# shellcheck source=/dev/null
source "$ROOT_DIR/infra/lifecycle/deploy/lib/tags.sh"

REGISTRY_PREFIX="${REGISTRY_PREFIX:-local/oal}"
TAG="$(resolve_image_tag)"
OUT_DIR="$ROOT_DIR/infra/lifecycle/build/out"
mkdir -p "$OUT_DIR"

build_image() {
  local name="$1"
  local dockerfile="$2"
  local ref="${REGISTRY_PREFIX}/${name}:${TAG}"
  echo "Building $ref"
  docker build -f "$ROOT_DIR/$dockerfile" -t "$ref" "$ROOT_DIR"
}

build_image "gateway-api" "src/services/Gateway/Gateway.Api/Dockerfile"
build_image "identity-api" "src/services/Identity/Identity.Api/Dockerfile"
build_image "catalog-api" "src/services/Catalog/Catalog.Api/Dockerfile"
build_image "web-nginx" "src/ui/web-app/Dockerfile"

cat > "$OUT_DIR/build-metadata.json" <<JSON
{
  "commit": "$(git -C "$ROOT_DIR" rev-parse HEAD)",
  "tag": "$TAG",
  "registryPrefix": "$REGISTRY_PREFIX",
  "images": [
    "${REGISTRY_PREFIX}/gateway-api:${TAG}",
    "${REGISTRY_PREFIX}/identity-api:${TAG}",
    "${REGISTRY_PREFIX}/catalog-api:${TAG}",
    "${REGISTRY_PREFIX}/web-nginx:${TAG}"
  ]
}
JSON

echo "Image metadata written to $OUT_DIR/build-metadata.json"
