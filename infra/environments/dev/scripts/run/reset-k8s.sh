#!/usr/bin/env bash
# Purpose: Reset developer runtime resources on local kind Kubernetes.
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

if [[ "$DELETE_CLUSTER" == "true" ]]; then
  bash "$ROOT_DIR/infra/environments/dev/scripts/run/down-k8s.sh" --tls "$TLS_MODE" --cluster-name "$CLUSTER_NAME" --delete-cluster
else
  bash "$ROOT_DIR/infra/environments/dev/scripts/run/down-k8s.sh" --tls "$TLS_MODE" --cluster-name "$CLUSTER_NAME"
fi
bash "$ROOT_DIR/infra/environments/dev/scripts/run/up-k8s.sh" --tls "$TLS_MODE" --cluster-name "$CLUSTER_NAME"
