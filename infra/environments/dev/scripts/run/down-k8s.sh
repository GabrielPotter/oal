#!/usr/bin/env bash
# Purpose: Stop developer runtime resources on local kind Kubernetes.
set -euo pipefail

TLS_MODE="local-ca"
CLUSTER_NAME="oal-dev"
DELETE_CLUSTER="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --tls) TLS_MODE="$2"; shift 2 ;;
    --cluster-name) CLUSTER_NAME="$2"; shift 2 ;;
    --delete-cluster) DELETE_CLUSTER="true"; shift ;;
    *) echo "Unknown argument: $1"; exit 2 ;;
  esac
done

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../.." && pwd)"
OVERLAY="$ROOT_DIR/infra/environments/dev/k8s/overlays/dev"

case "$TLS_MODE" in
  local-ca) OVERLAY="$ROOT_DIR/infra/environments/dev/k8s/overlays/dev-localca" ;;
  plain) OVERLAY="$ROOT_DIR/infra/environments/dev/k8s/overlays/dev" ;;
  *) echo "Unsupported --tls value: $TLS_MODE"; exit 2 ;;
esac

if command -v kubectl >/dev/null 2>&1; then
  kubectl delete -k "$OVERLAY" --ignore-not-found
fi

if [[ "$DELETE_CLUSTER" == "true" ]] && command -v kind >/dev/null 2>&1; then
  kind delete cluster --name "$CLUSTER_NAME"
fi
