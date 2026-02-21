# OAL Microservices Monorepo

Reusable template monorepo for Linux-first .NET microservices and React/Vite web UI.

## Purpose

This repository provides a production-oriented platform skeleton so teams can start from shared runtime, security, communication, and infrastructure conventions instead of rebuilding the foundation.

## Audience

- Product teams bootstrapping new backend + web systems.
- Platform engineers defining reusable technical baselines.
- Operators running dev, CI, on-prem, and GCP environments.

## Quick Start

```sh
export DOTNET_CLI_HOME="${DOTNET_CLI_HOME:-$PWD/.dotnet-home}"
dotnet restore microservices.sln
dotnet build microservices.sln --no-restore -m:1
```

```sh
cd src/ui/web-app
npm install
npm run build
```

```sh
infra/lifecycle/run/run-dev.sh up --mode k8s --tls local-ca
infra/lifecycle/run/run-dev.sh down --mode k8s
infra/lifecycle/run/run-dev.sh up --mode compose
```

## Documentation

All detailed documentation lives under `docs/`.

Start here:
- `docs/README.md`

Primary sections:
- `docs/architecture/`
- `docs/security/`
- `docs/runtime/`
- `docs/operations/`
- `docs/contracts/`
- `docs/contributing/`
