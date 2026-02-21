# Infra Migration Guide (Clean Break)

This repository moved from legacy `infra/scripts`, `infra/docker/compose`, and `infra/k8s` paths to the new lifecycle-first structure.

## Command Mapping

- Old: `infra/scripts/env/local-up.sh`
- New: `infra/lifecycle/run/run-dev.sh up`

- Old: `infra/scripts/env/local-down.sh`
- New: `infra/lifecycle/run/run-dev.sh down`

- Old: `infra/scripts/env/local-reset.sh`
- New: `infra/lifecycle/run/run-dev.sh reset`

- Old: `infra/scripts/init/tls-onprem.sh <domain> <email>`
- New: `infra/environments/onprem/scripts/tls/issue-letsencrypt.sh <domain> <email>`

- Old: `infra/scripts/env/tls-renew.sh`
- New: `infra/environments/onprem/scripts/tls/renew.sh`

- Old: `infra/scripts/verify/verify-all.sh`
- New: `infra/lifecycle/verify/verify-all.sh --target all`

- Old: `docker compose -f infra/docker/compose/docker-compose.dev.yml up --build -d`
- New: `infra/lifecycle/run/run-dev.sh up`

- Old: `docker compose -f infra/docker/compose/docker-compose.onprem-hardened.yml --env-file .env up --build -d`
- New: `infra/lifecycle/run/run-onprem.sh hardened --env-file .env`

- Old: `kubectl apply -k infra/k8s/overlays/gcp/prod`
- New: `kubectl apply -k infra/environments/gcp/k8s/overlays/prod`

- Old: `kubectl apply -k infra/k8s/overlays/onprem/prod`
- New: `kubectl apply -k infra/environments/onprem/k8s/overlays/prod`
