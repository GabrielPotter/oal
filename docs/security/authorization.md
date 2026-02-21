# Authorization

## Purpose

Define baseline authorization behavior for user-facing platform APIs.

## Scope

In scope:
- Scope policy and tenant policy defaults.
- Expected response behavior for authz failures.

Out of scope:
- Service-specific RBAC models.

## Baseline Assumptions

- Required API scope: `oal.api` (default).
- Required tenant claim for protected multi-tenant endpoints: `tenant_id`.
- User-facing business endpoints are exposed through `Gateway.Api` only.

## Rules

- Missing or invalid JWT: `401 Unauthorized`.
- Missing tenant claim on protected endpoint: `403 Forbidden`.
- Internal services remain private and not directly reachable from browsers.

## Concrete Commands and Examples

```sh
curl -i http://localhost:8080/api/frontend/me
curl -i -H "Authorization: Bearer <token-without-tenant-claim>" http://localhost:8080/api/frontend/bootstrap
```

## Failure Modes and Troubleshooting

- Unexpected `401`: verify authentication middleware order and token authority.
- Unexpected `403`: verify claim mapping and policy configuration.

## Related

- `docs/security/authentication.md`
- `docs/architecture/service-boundaries.md`
- `docs/architecture/communication-patterns.md`

## Last Review

- Date: February 21, 2026
- Owner role: Security Architect
