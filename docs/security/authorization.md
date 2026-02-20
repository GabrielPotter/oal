# Authorization

## Baseline

- Scope policy: request must include required API scope (`oal.api` by default).
- Tenant policy: request must include tenant claim (`tenant_id` by default).
- Missing/invalid JWT -> `401`.
- Missing tenant claim on protected multi-tenant endpoint -> `403`.

## User-Facing API

User-facing business endpoints are exposed via `Gateway.Api` only.
Internal services are expected to remain private and not directly reachable from browsers.
