# OAL Microservices Monorepo

Skeleton monorepo for .NET microservices and React/Vite UI with reusable platform building blocks.

## Platform Baseline

- Linux-first runtime.
- Primary database: PostgreSQL.
- Primary cache: Redis OSS (free/open source distribution).
- RabbitMQ support is available but not a primary planned dependency.
- Primary cloud target: Google Cloud (on-prem remains supported).
- UI is always a web application using React + TypeScript.

## What is included

- .NET service skeletons under `src/services/*`.
- Shared platform modules under `src/building-blocks/*`:
  - authentication
  - authorization
  - communication
  - encryption
  - persistence
  - messaging
  - observability
  - adapters: RabbitMQ publisher, EF Core + Npgsql db context skeleton
- React + Vite UI scaffold under `src/ui/web-app`.
- Nginx reverse proxy pattern for Browser -> Gateway.Api.
- Local infra baseline under `infra/environments/dev/docker/compose/stack.foundation.yml`:
  - Postgres
  - RabbitMQ (optional/non-primary)
  - Redis OSS
  - Keycloak (dev mode)
- Automation scripts under `infra/lifecycle/* and infra/environments/<target>/scripts/*`.

## Quick start

```bash
export DOTNET_CLI_HOME="${DOTNET_CLI_HOME:-$PWD/.dotnet-home}"
dotnet restore microservices.sln
dotnet build microservices.sln --no-restore -m:1
```

```bash
cd src/ui/web-app
npm install
npm run build
```

## Local infrastructure

```bash
infra/lifecycle/run/run-dev.sh up
infra/lifecycle/run/run-dev.sh down
```

```bash
infra/lifecycle/run/run-dev.sh up
```

## HTTPS Modes

On-prem HTTPS edge (Let's Encrypt + Nginx TLS termination):

```bash
infra/environments/onprem/scripts/tls/issue-letsencrypt.sh app.example.com admin@example.com
infra/lifecycle/run/run-onprem.sh bootstrap
```

GCP HTTPS edge (Ingress + managed certificate):

```bash
kubectl apply -k infra/environments/gcp/k8s/overlays/prod
```

On-prem HTTPS edge (Kubernetes + ingress controller + TLS secret):

```bash
kubectl apply -k infra/environments/onprem/k8s/overlays/prod
```

Security model:
- Browser/API calls are always HTTPS at the edge.
- Service-to-service communication remains HTTP on private network boundaries.
- Gateway is the only user-facing backend.

Secret provider patterns:
- GCP: Secret Manager + workload identity.
- On-prem: Vault/Kubernetes secret injection.

## Frontend Gateway API (BFF)

Gateway user-facing endpoints:
- `GET /api/frontend/auth/config`
- `GET /api/frontend/registration/url`
- `GET /api/frontend/me` (JWT + tenant claim required)
- `GET /api/frontend/bootstrap` (JWT + tenant claim required)

## Scaffold a new service

```bash
infra/lifecycle/build/new-service.sh Orders
```

This creates:
- `src/services/Orders/Orders.Api`
- `src/services/Orders/Orders.Tests`
- project references to all platform building blocks
- standardized `Program.cs` and `appsettings.json`
- solution entries in `microservices.sln`
