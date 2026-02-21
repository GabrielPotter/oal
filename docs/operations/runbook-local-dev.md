# Local Development Runbook

## Purpose

Provide a reproducible local environment aligned with production-like platform decisions.

## Scope

In scope:
- Local foundation stack lifecycle.
- Local HTTPS simulation options.

Out of scope:
- Production-grade hardening details.

## Baseline Assumptions

- Linux-compatible developer machine.
- Foundation services: PostgreSQL, Redis OSS, Keycloak.
- RabbitMQ optional and non-primary.

## Concrete Commands and Examples

Start/stop/reset:

```sh
infra/lifecycle/run/run-dev.sh up
infra/lifecycle/run/run-dev.sh down
infra/lifecycle/run/run-dev.sh reset
```

On-prem simulation:

```sh
infra/lifecycle/run/run-onprem.sh bootstrap
infra/lifecycle/run/run-onprem.sh hardened --env-file .env
```

Renew on-prem certificates:

```sh
infra/environments/onprem/scripts/tls/renew.sh
```

Access points:
- `http://localhost:8080` (web UI dev edge)
- `http://localhost:8088` (Keycloak)

## Failure Modes and Troubleshooting

- Services fail to boot: inspect compose logs and verify env file values.
- Auth endpoints unavailable: verify Keycloak startup and network mapping.

## Related

- `docs/runtime/environments.md`
- `docs/security/tls-self-signed-onprem.md`
- `docs/operations/runbook-ci.md`

## Last Review

- Date: February 21, 2026
- Owner role: Platform Operator
