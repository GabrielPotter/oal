#!/usr/bin/env bash
# Purpose: Support script for the infrastructure lifecycle workflow.
# Inputs: see inline logic and calling command arguments/environment variables.
# Outputs/artifacts: command output and exit status used by orchestrator scripts.
# Preconditions: required runtime dependencies must be installed.
# Failure modes + exit codes: returns non-zero on validation/execution failure.
# Examples: run via documented lifecycle entrypoints in infra/README.md.
# Security notes: avoid passing secrets in plain command-line arguments.
# Purpose: Verify .NET restore/build in fail-fast mode.
# Examples:
#   bash infra/lifecycle/verify/verify-dotnet.sh
#   DOTNET_CLI_TELEMETRY_OPTOUT=1 bash infra/lifecycle/verify/verify-dotnet.sh
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$ROOT_DIR"
dotnet --version
dotnet restore microservices.sln
dotnet build microservices.sln --no-restore -m:1
