# Infrastructure Layout

This repository uses a lifecycle-first and environment-first infrastructure model.

## Environment Domains

- `infra/environments/dev`: local developer environment.
- `infra/environments/onprem`: on-prem production target.
- `infra/environments/gcp`: Google Cloud production target.

## Lifecycle Domains

- `infra/lifecycle/prerequisites`: tool checks and interactive installation.
- `infra/lifecycle/build`: restore/build/image build.
- `infra/lifecycle/deploy`: full deployment pipelines.
- `infra/lifecycle/run`: runtime orchestration.
- `infra/lifecycle/verify`: fail-fast verification pipelines.

## Quick Start Matrix

1. Dev prerequisites: `infra/lifecycle/prerequisites/check-install.sh --target dev`
2. Dev run: `infra/lifecycle/run/run-dev.sh up`
3. On-prem hardened run: `infra/lifecycle/run/run-onprem.sh hardened --env-file .env`
4. GCP full deploy: `REGISTRY_PREFIX=<registry> infra/lifecycle/deploy/deploy-gcp.sh --env prod`
5. Global verify: `infra/lifecycle/verify/verify-all.sh --target all`

## Migration

If you previously used legacy `infra/scripts` or old compose/k8s paths, use `infra/MIGRATION.md`.
