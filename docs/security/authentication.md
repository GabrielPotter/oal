# Authentication

## Purpose

Document baseline identity and token validation model for platform services.

## Scope

In scope:
- Web sign-in flow and token type.
- Keycloak realm/client baseline.
- Gateway endpoints used by the web UI.

Out of scope:
- Product-specific user lifecycle policies.

## Baseline Assumptions

- Identity provider: Keycloak.
- Web flow: OpenID Connect Authorization Code with PKCE.
- Access tokens: JWT bearer tokens.

## Keycloak Baseline Model

- Realm: `oal`.
- Web client: `web-app` (public, PKCE enabled).
- Keycloak user federation/brokering is allowed.

Gateway UI support endpoints:
- `GET /api/frontend/auth/config`
- `GET /api/frontend/registration/url`

## Concrete Commands and Examples

```sh
infra/lifecycle/run/run-dev.sh up
curl -I http://localhost:8080/api/frontend/auth/config
```

## Failure Modes and Troubleshooting

- Invalid token signature: verify authority/issuer configuration.
- Login redirect loop: verify Keycloak client redirect URI settings.
- Missing JWKS resolution: verify Keycloak reachability from gateway.

## Related

- `docs/security/authorization.md`
- `docs/security/secrets.md`
- `docs/operations/runbook-local-dev.md`

## Last Review

- Date: February 21, 2026
- Owner role: Security Architect
