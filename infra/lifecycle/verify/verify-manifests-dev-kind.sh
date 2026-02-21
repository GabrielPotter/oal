#!/usr/bin/env bash
# Purpose: Validate dev kind overlays can render with kustomize.
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
# shellcheck source=/dev/null
source "$ROOT_DIR/infra/lifecycle/deploy/lib/kubernetes.sh"

kustomize_render "$ROOT_DIR/infra/environments/dev/k8s/overlays/dev" >/dev/null
kustomize_render "$ROOT_DIR/infra/environments/dev/k8s/overlays/dev-localca" >/dev/null

echo "Dev kind overlays validated"
