# Documentation Index

## Purpose

This is the single documentation hub for the OAL skeleton platform.

## Scope

In scope:
- Platform architecture, security, runtime, operations, and contract conventions.
- Environment and lifecycle scripts for dev, on-prem, and GCP.

Out of scope:
- Product-specific business requirements.
- Deep service-specific domain behavior.

## Baseline Assumptions

- Linux-first workloads and containers.
- PostgreSQL as primary relational database.
- Redis OSS as primary cache.
- RabbitMQ optional and non-primary.
- Google Cloud first-class target, on-prem supported.

## Start Paths

New product team:
1. `docs/architecture/system-overview.md`
2. `docs/security/authentication.md`
3. `docs/runtime/environments.md`
4. `docs/operations/runbook-local-dev.md`

Platform engineer:
1. `docs/architecture/communication-patterns.md`
2. `docs/security/secrets.md`
3. `docs/runtime/lifecycle-scripts.md`
4. `docs/contracts/http-openapi.md`

Operator:
1. `docs/operations/runbook-ci.md`
2. `docs/operations/runbook-production.md`
3. `docs/runtime/lifecycle-scripts.md`

## Documentation Map

- Architecture:
  - `docs/architecture/system-overview.md`
  - `docs/architecture/service-boundaries.md`
  - `docs/architecture/communication-patterns.md`
- Security:
  - `docs/security/authentication.md`
  - `docs/security/authorization.md`
  - `docs/security/encryption.md`
  - `docs/security/secrets.md`
  - `docs/security/tls-self-signed-onprem.md`
- Runtime:
  - `docs/runtime/environments.md`
  - `docs/runtime/lifecycle-scripts.md`
- Operations:
  - `docs/operations/runbook-local-dev.md`
  - `docs/operations/runbook-ci.md`
  - `docs/operations/runbook-production.md`
  - `docs/operations/migration-history.md`
- Contracts:
  - `docs/contracts/http-openapi.md`
  - `docs/contracts/messaging-events.md`
- Contributing:
  - `docs/contributing/documentation-standards.md`
  - `docs/contributing/documentation-template.md`
  - `docs/contributing/service-template-usage.md`

## Glossary

- BFF: Backend for Frontend, implemented by `Gateway.Api`.
- Platform target: runtime deployment profile (`dev`, `onprem`, `gcp`).
- Hard move: immediate relocation of docs without local README stubs.

## Related

- `README.md`
- `AGENTS.md`

## Last Review

- Date: February 21, 2026
- Owner role: Platform Maintainer
