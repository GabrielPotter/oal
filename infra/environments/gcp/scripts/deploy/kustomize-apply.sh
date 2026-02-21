#!/usr/bin/env bash
# Purpose: Apply GCP Kubernetes overlays for selected environment.
# Inputs:
#   --env {dev|test|prod}
# Examples:
#   bash infra/environments/gcp/scripts/deploy/kustomize-apply.sh --env dev
#   KUBECONFIG=~/.kube/config bash infra/environments/gcp/scripts/deploy/kustomize-apply.sh --env prod
set -euo pipefail

ENV_NAME=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --env) ENV_NAME="$2"; shift 2 ;;
    *) echo "Unknown argument: $1"; exit 2 ;;
  esac
done

if [[ -z "$ENV_NAME" ]]; then
  echo "Missing --env {dev|test|prod}"
  exit 2
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../.." && pwd)"
OVERLAY="$ROOT_DIR/infra/environments/gcp/k8s/overlays/$ENV_NAME"

if command -v kubectl >/dev/null 2>&1; then
  kubectl apply -k "$OVERLAY"
  exit 0
fi

if command -v kustomize >/dev/null 2>&1; then
  kustomize build "$OVERLAY" | kubectl apply -f -
  exit 0
fi

echo "Missing kubectl or kustomize"
exit 1
