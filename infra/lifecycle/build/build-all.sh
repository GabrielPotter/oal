#!/usr/bin/env bash
# Purpose: End-to-end build orchestration for platform artifacts.
# Inputs:
#   --target {dev|onprem|gcp}
#   --env {dev|test|prod}
# Outputs:
#   - compiled binaries, UI build, container images, build metadata.
# Preconditions:
#   - prerequisites for selected target installed.
# Failure modes:
#   - exits non-zero on first failing stage.
# Examples:
#   bash infra/lifecycle/build/build-all.sh --target dev --env dev
#   REGISTRY_PREFIX=us-central1-docker.pkg.dev/p/oal bash infra/lifecycle/build/build-all.sh --target gcp --env prod
# Security notes:
#   - reads environment variables only; do not embed secrets in command line history.
set -euo pipefail

TARGET=""
ENV_NAME=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target) TARGET="$2"; shift 2 ;;
    --env) ENV_NAME="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: $0 --target {dev|onprem|gcp} --env {dev|test|prod}"
      exit 0
      ;;
    *) echo "Unknown argument: $1"; exit 2 ;;
  esac
done

if [[ -z "$TARGET" || -z "$ENV_NAME" ]]; then
  echo "Missing required arguments --target and --env"
  exit 2
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

bash "$ROOT_DIR/infra/lifecycle/build/build-dotnet.sh"
bash "$ROOT_DIR/infra/lifecycle/build/build-ui.sh"
bash "$ROOT_DIR/infra/lifecycle/build/build-images.sh"

echo "Build completed for target=$TARGET env=$ENV_NAME"
