# Communication Patterns

## Purpose

Define default synchronous and optional asynchronous communication patterns.

## Scope

In scope:
- User-to-backend communication path.
- Internal service call conventions.
- Optional event-driven integration baseline.

Out of scope:
- Service-specific protocol optimization.

## Baseline Assumptions

- Primary pattern is synchronous HTTP/gRPC.
- Optional pattern is asynchronous messaging for decoupling/eventual consistency.
- RabbitMQ adapter support exists but is non-primary.

## Patterns and Rules

User to backend:
- UI calls `Gateway.Api` via `/api/frontend/*`.
- Gateway propagates incoming bearer token (initial strategy).
- Gateway propagates `X-Correlation-Id`.

Service to service:
- Standardized internal error contract.
- Authentication and authorization checks remain active.
- Tenant context for protected endpoints comes from `tenant_id` claim.

Messaging:
- Use event contracts with explicit versioning.
- Keep event consumers tolerant to additive change.

## Failure Modes and Troubleshooting

- Missing correlation ID in traces: verify gateway/header forwarding configuration.
- Tenant context missing: validate token claims and gateway pass-through behavior.
- Event incompatibility: verify event version contract alignment.

## Related

- `docs/architecture/service-boundaries.md`
- `docs/security/authentication.md`
- `docs/contracts/messaging-events.md`

## Last Review

- Date: February 21, 2026
- Owner role: Platform Architect
