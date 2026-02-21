# Migration History

## Purpose

Track major infrastructure/documentation layout migrations relevant to platform operators.

## Scope

In scope:
- Legacy path to lifecycle-first layout mapping.

Out of scope:
- Product-specific migration logs.

## Baseline Assumptions

- Current infra layout is lifecycle-first and environment-first.

## Legacy to Current Command Mapping

- `infra/scripts/env/local-up.sh` -> `infra/lifecycle/run/run-dev.sh up`
- `infra/scripts/env/local-down.sh` -> `infra/lifecycle/run/run-dev.sh down`
- `infra/scripts/env/local-reset.sh` -> `infra/lifecycle/run/run-dev.sh reset`
- `infra/scripts/init/tls-onprem.sh <domain> <email>` -> `infra/environments/onprem/scripts/tls/issue-letsencrypt.sh <domain> <email>`
- `infra/scripts/env/tls-renew.sh` -> `infra/environments/onprem/scripts/tls/renew.sh`
- `infra/scripts/verify/verify-all.sh` -> `infra/lifecycle/verify/verify-all.sh --target all`
- `docker compose -f infra/docker/compose/docker-compose.dev.yml up --build -d` -> `infra/lifecycle/run/run-dev.sh up`
- `docker compose -f infra/docker/compose/docker-compose.onprem-hardened.yml --env-file .env up --build -d` -> `infra/lifecycle/run/run-onprem.sh hardened --env-file .env`
- `kubectl apply -k infra/k8s/overlays/gcp/prod` -> `kubectl apply -k infra/environments/gcp/k8s/overlays/prod`
- `kubectl apply -k infra/k8s/overlays/onprem/prod` -> `kubectl apply -k infra/environments/onprem/k8s/overlays/prod`

## Failure Modes and Troubleshooting

- Old scripts still referenced in automation: update to lifecycle paths before release.

## Related

- `docs/runtime/lifecycle-scripts.md`
- `docs/operations/runbook-production.md`

## Last Review

- Date: February 21, 2026
- Owner role: Platform Maintainer
