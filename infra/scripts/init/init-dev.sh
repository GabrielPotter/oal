#!/usr/bin/env bash
set -euo pipefail

echo "Initializing local developer prerequisites..."
mkdir -p .secrets
[ -f .env ] || cp .env.example .env
