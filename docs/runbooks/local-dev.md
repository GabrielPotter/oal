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
bash infra/scripts/env/local-up.sh
bash infra/scripts/env/local-down.sh
```

```bash
docker compose -f infra/docker/compose/docker-compose.dev.yml up --build
```

## HTTPS Profile (On-Prem Simulation)

```bash
bash infra/scripts/init/tls-onprem.sh app.example.com admin@example.com
docker compose -f infra/docker/compose/docker-compose.onprem-https.yml up --build -d
```

Renew certificates:

```bash
bash infra/scripts/env/tls-renew.sh
```

## Access Points

- Web UI (Nginx dev): `http://localhost:8080`
- Web UI (Nginx TLS profile): `https://app.example.com`
- Keycloak admin/auth: `http://localhost:8088`
