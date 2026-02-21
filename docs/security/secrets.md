# Secrets and Configuration Strategy

Platform services use the same configuration keys across all targets.
Only the secret source changes by environment.

## Contract

Required configuration keys:
- `Authentication:*`
- `Authorization:*`
- `Persistence:*`
- `Messaging:*`
- `Encryption:*`
- `Runtime:PlatformTarget` (`dev`, `gcp`, or `onprem`)

## GCP pattern

- Store secrets in Secret Manager.
- Bind workload identity to service account.
- Inject secrets to pods through External Secrets or CSI driver.

## On-prem pattern

- Store secrets in Vault or Kubernetes secrets.
- Inject as environment variables or secret volume mount.
- Reference secret key contract from `infra/environments/onprem/manifests/runtime-secrets.example.yaml`.

## Policy

- No hardcoded production secrets in source-controlled appsettings.
- Runtime startup validates required keys and fails fast when missing.
