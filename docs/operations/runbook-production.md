# Production Runbook

## Purpose

Define production runtime expectations for GCP-first and on-prem compatible operation.

## Scope

In scope:
- Production baseline requirements.
- TLS policy and deployment overlays.

Out of scope:
- Product-specific incident and escalation playbooks.

## Baseline Assumptions

- Linux runtime.
- PostgreSQL primary relational store.
- Redis OSS primary cache.
- RabbitMQ only when explicitly required.

## HTTPS and TLS Policy

- User-facing traffic must be HTTPS only.
- HTTP must redirect to HTTPS.
- Internal service traffic may remain HTTP on private boundaries.

On-prem TLS helpers:
- `infra/environments/onprem/scripts/tls/issue-letsencrypt.sh`
- `infra/environments/onprem/scripts/tls/renew.sh`

GCP TLS baseline:
- Ingress + `ManagedCertificate` overlays under `infra/environments/gcp/k8s/overlays/*`.

On-prem Kubernetes overlays:
- `infra/environments/onprem/k8s/overlays/{dev,test,prod}`

## Concrete Commands and Examples

```sh
REGISTRY_PREFIX=<registry> infra/lifecycle/deploy/deploy-gcp.sh --env prod
infra/lifecycle/deploy/deploy-onprem.sh --env prod --mode k8s
infra/lifecycle/verify/verify-all.sh --target all
```

## Failure Modes and Troubleshooting

- TLS termination errors: verify overlay config and certificate references.
- Secret injection failure: validate runtime secret contract before deploy.

## Related

- `docs/runtime/environments.md`
- `docs/security/encryption.md`
- `docs/security/secrets.md`

## Last Review

- Date: February 21, 2026
- Owner role: Platform Operator
