# Service Boundaries

## Purpose

Define ownership and boundary rules for reusable microservice skeletons.

## Scope

In scope:
- User-facing versus internal service boundaries.
- Contract-first requirements for inter-service communication.

Out of scope:
- Business bounded-context modeling details.

## Baseline Assumptions

- Each service owns its API contract and persistence schema lifecycle.
- `Gateway.Api` aggregates frontend use-cases.
- Direct browser access to internal services is disallowed.

## Boundary Rules

- Public boundary:
  - Browser/web client communicates only with `Gateway.Api`.
- Private boundary:
  - Internal APIs are reachable only from trusted network segments.
- Contract-first:
  - HTTP APIs are documented under `docs/contracts/http-openapi.md`.
  - Messaging contracts are documented under `docs/contracts/messaging-events.md`.
- Cross-cutting consistency:
  - Correlation ID propagation is mandatory.
  - Authn/authz and tenant context are consistently enforced.

## Failure Modes and Troubleshooting

- Boundary bypass in local setup: ensure reverse proxy and service ports are not exposed publicly.
- Contract drift: update contract docs and implementation in the same change.

## Related

- `docs/architecture/system-overview.md`
- `docs/architecture/communication-patterns.md`
- `docs/contracts/http-openapi.md`

## Last Review

- Date: February 21, 2026
- Owner role: Platform Architect
