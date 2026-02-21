# Secrets and Configuration Strategy

## Purpose

Define environment-agnostic secret key contracts and environment-specific secret sources.

## Scope

In scope:
- Required shared configuration key families.
- GCP and on-prem secret sourcing patterns.
- On-prem required secret schema.

Out of scope:
- Storing real secret values in repository.

## Baseline Assumptions

- Services keep stable key names across targets.
- Only secret source/injection mechanism changes by environment.
- Runtime validates required keys and fails fast when missing.

## Contract

Required key families:
- `Authentication:*`
- `Authorization:*`
- `Persistence:*`
- `Messaging:*`
- `Encryption:*`
- `Runtime:PlatformTarget` (`dev`, `gcp`, `onprem`)

## Secret Source Patterns

GCP pattern:
- Secret Manager as source of truth.
- Workload Identity bound service accounts.
- Injection via External Secrets or CSI driver.

On-prem pattern:
- Vault or Kubernetes Secrets.
- Injection via environment variables or secret volume mounts.
- Runtime contract reference: `infra/environments/onprem/manifests/runtime-secrets.example.yaml`.

## On-Prem Secrets Schema

Required keys:
- `POSTGRES_PASSWORD`
- `RABBITMQ_PASSWORD`
- `KEYCLOAK_ADMIN_PASSWORD`
- `PERSISTENCE_CONNECTION_STRING`

Injection options:
1. Compose mode via `--env-file`.
2. Kubernetes mode via `platform-runtime-secrets`.

## Concrete Commands and Examples

```sh
infra/lifecycle/run/run-onprem.sh hardened --env-file .env
infra/lifecycle/prerequisites/check-install.sh --target gcp --mode check-only
```

## Failure Modes and Troubleshooting

- Startup fails with missing key: verify secret mount/injection and key names.
- Wrong target profile behavior: verify `Runtime:PlatformTarget` value.

## Related

- `docs/security/encryption.md`
- `docs/runtime/environments.md`
- `docs/runtime/lifecycle-scripts.md`

## Last Review

- Date: February 21, 2026
- Owner role: Security Architect
