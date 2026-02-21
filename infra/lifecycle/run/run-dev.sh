#!/usr/bin/env bash
# Purpose: Start/stop/reset developer environment stacks.
# Inputs:
#   [up|down|reset] (default up)
#   --mode {k8s|compose} (default k8s)
#   --tls {local-ca|plain} for --mode k8s (default local-ca)
#   --cluster-name <name> for --mode k8s (default oal-dev)
#   --delete-cluster for down/reset in --mode k8s
# Examples:
#   bash infra/lifecycle/run/run-dev.sh up
#   bash infra/lifecycle/run/run-dev.sh up --mode k8s --tls local-ca
#   bash infra/lifecycle/run/run-dev.sh up --mode compose
set -euo pipefail

ACTION="up"
MODE="k8s"
TLS_MODE="local-ca"
CLUSTER_NAME="oal-dev"
DELETE_CLUSTER="false"

if [[ $# -gt 0 && "$1" != --* ]]; then
  ACTION="$1"
  shift
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode) MODE="$2"; shift 2 ;;
    --tls) TLS_MODE="$2"; shift 2 ;;
    --cluster-name) CLUSTER_NAME="$2"; shift 2 ;;
    --delete-cluster) DELETE_CLUSTER="true"; shift ;;
    *) echo "Unknown argument: $1"; exit 2 ;;
  esac
done

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

case "$MODE" in
  k8s)
    case "$ACTION" in
      up)
        bash "$ROOT_DIR/infra/environments/dev/scripts/run/up-k8s.sh" --tls "$TLS_MODE" --cluster-name "$CLUSTER_NAME"
        ;;
      down)
        if [[ "$DELETE_CLUSTER" == "true" ]]; then
          bash "$ROOT_DIR/infra/environments/dev/scripts/run/down-k8s.sh" --tls "$TLS_MODE" --cluster-name "$CLUSTER_NAME" --delete-cluster
        else
          bash "$ROOT_DIR/infra/environments/dev/scripts/run/down-k8s.sh" --tls "$TLS_MODE" --cluster-name "$CLUSTER_NAME"
        fi
        ;;
      reset)
        if [[ "$DELETE_CLUSTER" == "true" ]]; then
          bash "$ROOT_DIR/infra/environments/dev/scripts/run/reset-k8s.sh" --tls "$TLS_MODE" --cluster-name "$CLUSTER_NAME" --delete-cluster
        else
          bash "$ROOT_DIR/infra/environments/dev/scripts/run/reset-k8s.sh" --tls "$TLS_MODE" --cluster-name "$CLUSTER_NAME"
        fi
        ;;
      *)
        echo "Unsupported action: $ACTION"
        exit 2
        ;;
    esac
    ;;
  compose)
    case "$ACTION" in
      up)
        bash "$ROOT_DIR/infra/environments/dev/scripts/run/up.sh"
        docker compose -f "$ROOT_DIR/infra/environments/dev/docker/compose/stack.app.yml" up --build -d
        docker compose -f "$ROOT_DIR/infra/environments/dev/docker/compose/stack.app.yml" ps
        ;;
      down)
        docker compose -f "$ROOT_DIR/infra/environments/dev/docker/compose/stack.app.yml" down --remove-orphans
        bash "$ROOT_DIR/infra/environments/dev/scripts/run/down.sh"
        ;;
      reset)
        docker compose -f "$ROOT_DIR/infra/environments/dev/docker/compose/stack.app.yml" down -v --remove-orphans
        bash "$ROOT_DIR/infra/environments/dev/scripts/run/reset.sh"
        ;;
      *)
        echo "Unsupported action: $ACTION"
        exit 2
        ;;
    esac
    ;;
  *)
    echo "Unsupported mode: $MODE"
    exit 2
    ;;
esac
