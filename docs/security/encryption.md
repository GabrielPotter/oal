# Encryption

## Purpose

Define encryption expectations for data in transit and at rest.

## Scope

In scope:
- Edge TLS requirements.
- Internal traffic baseline.
- Secret-backed encryption material handling.

Out of scope:
- Product-specific cryptographic protocol selection.

## Baseline Assumptions

- User-facing traffic is HTTPS only.
- Internal service traffic may be HTTP on private boundaries.
- Certificates and keys are never hardcoded in source-controlled app config.

## Concrete Commands and Examples

```sh
infra/lifecycle/run/run-onprem.sh bootstrap
kubectl apply -k infra/environments/gcp/k8s/overlays/prod
```

Self-signed local/on-prem test profile:
- `docs/security/tls-self-signed-onprem.md`

## Failure Modes and Troubleshooting

- Browser TLS warning: verify trusted CA and certificate hostnames.
- TLS termination mismatch: verify edge config mounts and certificate paths.

## Related

- `docs/security/secrets.md`
- `docs/security/tls-self-signed-onprem.md`
- `docs/operations/runbook-production.md`

## Last Review

- Date: February 21, 2026
- Owner role: Security Architect
