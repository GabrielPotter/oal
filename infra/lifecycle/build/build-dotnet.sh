#!/usr/bin/env bash
# Purpose: Restore and build all .NET projects in fail-fast mode.
# Inputs: none (uses repository root).
# Outputs: compiled assemblies in bin/obj folders.
# Preconditions: dotnet SDK installed.
# Failure modes: exits non-zero on restore/build failure.
# Examples:
#   bash infra/lifecycle/build/build-dotnet.sh
#   DOTNET_CLI_TELEMETRY_OPTOUT=1 bash infra/lifecycle/build/build-dotnet.sh
# Security notes: no secrets read or written.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "$ROOT_DIR"

dotnet --version
dotnet restore microservices.sln
dotnet build microservices.sln --no-restore -m:1
