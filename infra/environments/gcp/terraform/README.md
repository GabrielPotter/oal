# Terraform Layout

This directory contains GCP-specific Terraform composition.

- `modules/*`: reusable GCP modules (network, gke, iam, artifact registry).
- `envs/{dev,test,prod}`: environment compositions consuming shared modules.

On-prem deployment remains provider-agnostic and is documented under `infra/environments/onprem`.
