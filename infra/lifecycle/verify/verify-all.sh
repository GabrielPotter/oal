#!/usr/bin/env bash
# Purpose: Orchestrate full verification pipeline across code and infra.
# Inputs:
#   --target {dev|onprem|gcp|all} (default all)
# Examples:
#   bash infra/lifecycle/verify/verify-all.sh --target all
#   bash infra/lifecycle/verify/verify-all.sh --target gcp
set -euo pipefail

TARGET="all"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --target) TARGET="$2"; shift 2 ;;
    *) echo "Unknown argument: $1"; exit 2 ;;
  esac
done

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

bash "$ROOT_DIR/infra/lifecycle/verify/verify-dotnet.sh"
bash "$ROOT_DIR/infra/lifecycle/verify/verify-ui.sh"
bash "$ROOT_DIR/infra/lifecycle/verify/verify-docs.sh"

if [[ "$TARGET" == "all" || "$TARGET" == "onprem" ]]; then
  bash "$ROOT_DIR/infra/lifecycle/verify/verify-manifests-onprem.sh"
  docker compose -f "$ROOT_DIR/infra/environments/onprem/docker/compose/stack.bootstrap.yml" config >/dev/null
  if [[ -f "$ROOT_DIR/.env" ]]; then
    docker compose --env-file "$ROOT_DIR/.env" -f "$ROOT_DIR/infra/environments/onprem/docker/compose/stack.hardened.yml" config >/dev/null
  else
    docker compose --env-file "$ROOT_DIR/infra/environments/onprem/config/env.example" -f "$ROOT_DIR/infra/environments/onprem/docker/compose/stack.hardened.yml" config >/dev/null
  fi
fi

if [[ "$TARGET" == "all" || "$TARGET" == "dev" ]]; then
  docker compose -f "$ROOT_DIR/infra/environments/dev/docker/compose/stack.foundation.yml" config >/dev/null
  docker compose -f "$ROOT_DIR/infra/environments/dev/docker/compose/stack.app.yml" config >/dev/null
fi

if [[ "$TARGET" == "all" || "$TARGET" == "gcp" ]]; then
  bash "$ROOT_DIR/infra/lifecycle/verify/verify-manifests-gcp.sh"
fi

echo "Verification completed for target=$TARGET"
