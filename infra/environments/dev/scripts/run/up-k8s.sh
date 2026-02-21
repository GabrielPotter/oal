#!/usr/bin/env bash
# Purpose: Start developer runtime on local kind Kubernetes.
set -euo pipefail

TLS_MODE="local-ca"
CLUSTER_NAME="oal-dev"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --tls) TLS_MODE="$2"; shift 2 ;;
    --cluster-name) CLUSTER_NAME="$2"; shift 2 ;;
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

if ! command -v kind >/dev/null 2>&1; then
  echo "Missing required command: kind"
  exit 1
fi

if ! command -v kubectl >/dev/null 2>&1; then
  echo "Missing required command: kubectl"
  exit 1
fi

if ! kind get clusters | grep -Fxq "$CLUSTER_NAME"; then
  kind create cluster --name "$CLUSTER_NAME"
fi

kubectl cluster-info --context "kind-$CLUSTER_NAME" >/dev/null
kubectl config use-context "kind-$CLUSTER_NAME" >/dev/null
kubectl apply -k "$OVERLAY"

if [[ "$TLS_MODE" == "local-ca" && -n "${DEV_EDGE_TLS_CERT_FILE:-}" && -n "${DEV_EDGE_TLS_KEY_FILE:-}" ]]; then
  kubectl -n oal-dev create secret tls oal-dev-edge-tls \
    --cert "$DEV_EDGE_TLS_CERT_FILE" \
    --key "$DEV_EDGE_TLS_KEY_FILE" \
    --dry-run=client -o yaml | kubectl apply -f -
fi

kubectl -n oal-dev get pods
