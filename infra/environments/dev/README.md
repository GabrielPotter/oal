# Dev Environment

Purpose: provide reproducible local developer runtime with foundation services and app services.

## Components

- Foundation stack: PostgreSQL, Redis, RabbitMQ, Keycloak.
- App stack: web-nginx, gateway-api, identity-api, catalog-api.
- Local cluster runtime: `kind` (Kubernetes-in-Docker) for dev-only cluster workflows.
- Tooling parity: dev uses the same API/deployment tooling surface as on-prem (`docker`, `docker compose`, `kind`, `kubectl`, `kustomize`).

## Config

- `infra/environments/dev/config/env.example`: local defaults and key descriptions.
- No production credentials should be used in this environment.

## Run Commands

1. Start all: `infra/lifecycle/run/run-dev.sh up`
2. Stop all: `infra/lifecycle/run/run-dev.sh down`
3. Reset volumes: `infra/lifecycle/run/run-dev.sh reset`
