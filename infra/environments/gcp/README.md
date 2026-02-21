# GCP Environment

Purpose: production-grade Google Cloud deployment target.

## Scope

- Terraform provisioning under `terraform/`.
- Kubernetes base and overlays under `k8s/`.
- Deployment scripts under `scripts/deploy/`.

## Full Pipeline

1. Build images.
2. Push images to Artifact Registry.
3. Apply Terraform for target environment.
4. Apply Kustomize overlay for target environment.
5. Run smoke checks.

Primary command:

`REGISTRY_PREFIX=<registry> infra/lifecycle/deploy/deploy-gcp.sh --env prod`
