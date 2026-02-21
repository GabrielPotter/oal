# Lifecycle: Build

Build stage compiles backend, frontend, and container images.

## Entry point

`infra/lifecycle/build/build-all.sh --target {dev|onprem|gcp} --env {dev|test|prod}`

## Outputs

- Compiled binaries under project `bin/` directories.
- UI artifacts in `src/ui/web-app/dist`.
- Build metadata in `infra/lifecycle/build/out/build-metadata.json`.
