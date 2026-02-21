#!/usr/bin/env bash
# Purpose: Install dependencies and build the React/Vite UI.
# Inputs: none.
# Outputs: UI build artifacts under src/ui/web-app/dist.
# Preconditions: node and npm installed.
# Failure modes: exits non-zero on npm install/typecheck/build failure.
# Examples:
#   bash infra/lifecycle/build/build-ui.sh
#   npm_config_loglevel=warn bash infra/lifecycle/build/build-ui.sh
# Security notes: does not handle credentials directly.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
pushd "$ROOT_DIR/src/ui/web-app" >/dev/null
npm ci
npm run typecheck
npm run build
popd >/dev/null
