# Lifecycle: Verify

Fail-fast validation of code, manifests, and runtime contracts.

## Full verify

`infra/lifecycle/verify/verify-all.sh --target {dev|onprem|gcp|all}`

## Individual stages

- `verify-dotnet.sh`
- `verify-ui.sh`
- `verify-manifests-onprem.sh`
- `verify-manifests-gcp.sh`
- `verify-deploy-contract.sh`
