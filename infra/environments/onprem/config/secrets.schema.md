# On-Prem Secrets Schema

## Purpose

Defines required secret keys and expected format for on-prem runtime.

## Required keys

- `POSTGRES_PASSWORD`: database credential for PostgreSQL.
- `RABBITMQ_PASSWORD`: broker credential.
- `KEYCLOAK_ADMIN_PASSWORD`: bootstrap/admin password for identity service.
- `PERSISTENCE_CONNECTION_STRING`: full connection string consumed by services.

## Injection options

1. Compose mode: `--env-file` passed to hardened stack.
2. Kubernetes mode: create `platform-runtime-secrets` from secure store.

## Security guidance

- Never commit real secret values.
- Rotate credentials on schedule and incident response.
- Restrict access to env files and secret manifests.
