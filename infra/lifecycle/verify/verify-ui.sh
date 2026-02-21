#!/usr/bin/env bash
# Purpose: Support script for the infrastructure lifecycle workflow.
# Inputs: see inline logic and calling command arguments/environment variables.
# Outputs/artifacts: command output and exit status used by orchestrator scripts.
# Preconditions: required runtime dependencies must be installed.
# Failure modes + exit codes: returns non-zero on validation/execution failure.
# Examples: run via documented lifecycle entrypoints in infra/README.md.
# Security notes: avoid passing secrets in plain command-line arguments.
# Purpose: Verify UI dependency graph, type safety, and production build.
# Examples:
#   bash infra/lifecycle/verify/verify-ui.sh
#   npm_config_loglevel=warn bash infra/lifecycle/verify/verify-ui.sh
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
pushd "$ROOT_DIR/src/ui/web-app" >/dev/null
npm ci
npm run typecheck
npm run build
popd >/dev/null
