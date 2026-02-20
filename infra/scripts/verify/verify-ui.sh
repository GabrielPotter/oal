#!/usr/bin/env bash
set -euo pipefail

pushd src/ui/web-app >/dev/null
npm install
npm run typecheck
npm run build
popd >/dev/null
