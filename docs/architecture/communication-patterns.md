# Communication Patterns

## Baseline

- Primary pattern: synchronous HTTP/gRPC service-to-service APIs.
- Optional pattern: asynchronous messaging when needed for decoupling or eventual consistency.
- RabbitMQ integration can remain available as an optional adapter, but it is not the default design center.

## Required Cross-Cutting Rules

- Correlation ID propagation across all service boundaries.
- Standardized error contract for internal service calls.
- Authentication and authorization enforced on internal and external endpoints.
- Tenant context is required from JWT claim (`tenant_id`) for protected business endpoints.

## User to Backend Communication

- UI communicates only with `Gateway.Api`.
- `Gateway.Api` exposes user-facing endpoints under `/api/frontend/*`.
- `Gateway.Api` forwards calls to internal services with:
  - incoming bearer token pass-through (initial strategy)
  - `X-Correlation-Id` propagation for tracing and audit
- HTTPS is mandatory between browser and edge.
- HTTP is allowed between internal services on private network.
