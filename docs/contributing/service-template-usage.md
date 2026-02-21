# Service Template Usage

## Purpose

Describe how reusable service skeletons and generators are expected to be used.

## Scope

In scope:
- Service scaffolding entrypoint.
- Expected generated project structure.

Out of scope:
- Domain-specific service implementation.

## Baseline Assumptions

- Service templates are maintained under `src/tools/Templates`.
- New services should consume shared building blocks by default.

## Concrete Commands and Examples

Scaffold a service:

```sh
infra/lifecycle/build/new-service.sh Orders
```

Expected output:
- `src/services/Orders/Orders.Api`
- `src/services/Orders/Orders.Tests`
- Solution entries in `microservices.sln`

## Failure Modes and Troubleshooting

- Missing references to shared building blocks: verify template defaults and regenerate if needed.
- Service not added to solution: verify scaffold script post-steps.

## Related

- `docs/architecture/service-boundaries.md`
- `docs/runtime/lifecycle-scripts.md`

## Last Review

- Date: February 21, 2026
- Owner role: Platform Maintainer
