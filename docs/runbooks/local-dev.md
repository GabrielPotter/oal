# Local Development Runbook

## Goal

Provide a reproducible local Linux-compatible environment aligned with production-like platform choices.

## Local Dependency Stack

- PostgreSQL
- Redis OSS
- Keycloak
- RabbitMQ (optional, non-primary)

## Commands

```bash
infra/lifecycle/run/run-dev.sh up
infra/lifecycle/run/run-dev.sh down
```

```bash
infra/lifecycle/run/run-dev.sh reset
```

## HTTPS Profile (On-Prem Simulation)

```bash
infra/environments/onprem/scripts/tls/issue-letsencrypt.sh app.example.com admin@example.com
infra/lifecycle/run/run-onprem.sh bootstrap
```

Hardened on-prem bootstrap profile (no Keycloak `start-dev`):

```bash
infra/lifecycle/run/run-onprem.sh hardened --env-file .env
```

Renew certificates:

```bash
infra/environments/onprem/scripts/tls/renew.sh
```

## Access Points

- Web UI (Nginx dev): `http://localhost:8080`
- Web UI (Nginx TLS profile): `https://app.example.com`
- Keycloak admin/auth: `http://localhost:8088`
