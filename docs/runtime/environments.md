# Runtime Environments

## Purpose

Describe runtime target profiles and their baseline components.

## Scope

In scope:
- `dev`, `onprem`, and `gcp` environment responsibilities.
- Shared versus target-specific runtime expectations.

Out of scope:
- Product-specific scaling and SLO tuning.

## Baseline Assumptions

- All targets keep platform contract parity where practical.
- Linux container runtime is the baseline for all targets.

## Environment Profiles

Dev:
- Primary workflow: local Kubernetes on `kind`.
- Default TLS profile: local CA (`app.local`, `id.local`) with trusted root.
- Compose remains available as fallback for rapid troubleshooting.

On-prem:
- Template/adaptation profile, not a fixed concrete cluster topology.
- Bootstrap compose profile and hardened compose profile remain as reference implementations.
- Kubernetes overlays under `infra/environments/onprem/k8s/overlays/{dev,test,prod}` are baseline templates.
- Certificate source is deployment-specific (local CA or public domain/issuer).

GCP:
- Terraform provisioning under `infra/environments/gcp/terraform`.
- Kubernetes overlays under `infra/environments/gcp/k8s/overlays/{dev,test,prod}`.
- Deployment pipeline combines image build/push + infra apply + app apply.

## Concrete Commands and Examples

```sh
infra/lifecycle/run/run-dev.sh up --mode k8s --tls local-ca
infra/lifecycle/run/run-dev.sh up --mode compose
infra/lifecycle/run/run-onprem.sh hardened --env-file .env
REGISTRY_PREFIX=<registry> infra/lifecycle/deploy/deploy-gcp.sh --env prod
```

## Failure Modes and Troubleshooting

- Environment drift: run verify scripts before deploy.
- Secret contract mismatch: verify key names in `docs/security/secrets.md`.

## Related

- `docs/runtime/lifecycle-scripts.md`
- `docs/operations/runbook-production.md`
- `docs/security/secrets.md`

## Last Review

- Date: February 21, 2026
- Owner role: Platform Maintainer
