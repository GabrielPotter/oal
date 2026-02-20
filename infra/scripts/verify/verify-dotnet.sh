#!/usr/bin/env bash
set -euo pipefail

export DOTNET_CLI_HOME="${DOTNET_CLI_HOME:-$(pwd)/.dotnet-home}"
dotnet --version

echo "Attempting solution restore/build (may require internet for NuGet)"
dotnet restore microservices.sln || true
dotnet build microservices.sln --no-restore -m:1 || true
