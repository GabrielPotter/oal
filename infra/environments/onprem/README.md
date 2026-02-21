# On-Prem Environment

Purpose: production-grade on-prem deployment target with both compose and Kubernetes options.

## Deployment Tracks

- Bootstrap compose mode (`stack.bootstrap.yml`) for initial bring-up.
- Hardened compose mode (`stack.hardened.yml`) for stricter production posture.
- Kubernetes overlays under `k8s/overlays/{dev,test,prod}`.

## Prerequisites

See `infra/environments/onprem/prerequisites/README.md`.

## Security Inputs

- `infra/environments/onprem/config/env.example`
- `infra/environments/onprem/config/secrets.schema.md`
- `infra/environments/onprem/manifests/runtime-secrets.example.yaml`

## TLS Lifecycle

- Issue cert: `infra/environments/onprem/scripts/tls/issue-letsencrypt.sh <domain> <email>`
- Renew cert: `infra/environments/onprem/scripts/tls/renew.sh`
