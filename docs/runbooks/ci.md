# CI Runbook

## Required validation lanes

1. `dotnet-and-ui-verify`
2. `gcp-manifests-validate`
3. `onprem-manifests-validate`

Reference workflow:
- `ci/pipelines/dual-target-validate.yml`

Local equivalents:

```bash
infra/lifecycle/verify/verify-dotnet.sh
infra/lifecycle/verify/verify-ui.sh
infra/lifecycle/verify/verify-manifests-gcp.sh
infra/lifecycle/verify/verify-manifests-onprem.sh
```
