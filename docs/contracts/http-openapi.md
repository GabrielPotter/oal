# HTTP OpenAPI Contracts

## Purpose

Define where and how service HTTP API contracts are documented and versioned.

## Scope

In scope:
- OpenAPI specification storage and governance expectations.

Out of scope:
- Service-specific endpoint design details.

## Baseline Assumptions

- API contracts are versioned and reviewed with implementation changes.
- Contract-first approach is mandatory for service boundary changes.

## Contract Location

- Store OpenAPI specs under `contracts/http/openapi/`.
- Use consistent naming and versioning conventions per service.

## Concrete Commands and Examples

```sh
rg --files contracts/http/openapi
```

## Failure Modes and Troubleshooting

- Contract drift: ensure spec update is part of the same change as handler changes.

## Related

- `docs/architecture/service-boundaries.md`
- `docs/architecture/communication-patterns.md`
- `docs/contracts/messaging-events.md`

## Last Review

- Date: February 21, 2026
- Owner role: API Architect
