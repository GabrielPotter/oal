# Authentication

## Baseline

- Identity provider: Keycloak.
- Flow for web UI: OpenID Connect Authorization Code + PKCE.
- Token type: JWT bearer access token.

## Keycloak Model

- Realm: `oal`.
- Web client: `web-app` (public client, PKCE enabled).
- Keycloak has its own user store and can broker identities from external IdPs.

## Gateway Endpoints for UI

- `GET /api/frontend/auth/config`
- `GET /api/frontend/registration/url`
