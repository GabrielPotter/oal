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
- `kind` is the primary local runtime orchestrator.
- Default dev TLS profile uses local CA certificates.
- RabbitMQ optional and non-primary.

## Concrete Commands and Examples

Start/stop/reset:

```sh
infra/lifecycle/run/run-dev.sh up --mode k8s --tls local-ca
infra/lifecycle/run/run-dev.sh down --mode k8s
infra/lifecycle/run/run-dev.sh reset --mode k8s
```

Create/update TLS secret from local CA files (optional helper path):

```sh
DEV_EDGE_TLS_CERT_FILE=infra/certs/selfsigned/app.local/app.local.crt \
DEV_EDGE_TLS_KEY_FILE=infra/certs/selfsigned/app.local/app.local.key \
infra/lifecycle/run/run-dev.sh up --mode k8s --tls local-ca
```

Compose fallback:

```sh
infra/lifecycle/run/run-dev.sh up --mode compose
infra/lifecycle/run/run-dev.sh down --mode compose
```

On-prem baseline simulation:

```sh
infra/lifecycle/run/run-onprem.sh bootstrap
infra/lifecycle/run/run-onprem.sh hardened --env-file .env
```

Renew on-prem certificates:

```sh
infra/environments/onprem/scripts/tls/renew.sh
```

Access points:
- `https://app.local` (kind + local-ca profile)
- `http://localhost:8080` (compose fallback)

## Failure Modes and Troubleshooting

- Services fail to boot: inspect compose logs and verify env file values.
- Ingress/TLS issue on kind: verify local CA trust and `oal-dev-edge-tls` secret contents.
- Auth endpoints unavailable: verify Keycloak startup and network mapping.

## Related

- `docs/runtime/environments.md`
- `docs/security/tls-self-signed-onprem.md`
- `docs/operations/runbook-ci.md`

## Last Review

- Date: February 21, 2026
- Owner role: Platform Operator
