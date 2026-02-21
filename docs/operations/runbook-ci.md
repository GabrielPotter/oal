# CI Runbook

## Purpose

Describe mandatory validation lanes and their local equivalents.

## Scope

In scope:
- CI validation jobs for code, manifests, and documentation.

Out of scope:
- CD release orchestration.

## Baseline Assumptions

- CI pipeline definition: `ci/pipelines/dual-target-validate.yml`.
- Verification scripts are maintained under `infra/lifecycle/verify`.

## Required Validation Lanes

1. `dotnet-and-ui-verify`
2. `docs-validate`
3. `dev-kind-manifests-validate`
4. `gcp-manifests-validate`
5. `onprem-manifests-validate`

## Concrete Commands and Examples

```sh
infra/lifecycle/verify/verify-dotnet.sh
infra/lifecycle/verify/verify-ui.sh
infra/lifecycle/verify/verify-docs.sh
infra/lifecycle/verify/verify-manifests-dev-kind.sh
infra/lifecycle/verify/verify-manifests-gcp.sh
infra/lifecycle/verify/verify-manifests-onprem.sh
```

## Failure Modes and Troubleshooting

- Docs validation fails on markdown placement: move non-root docs under `docs/**`.
- Broken link check fails: fix relative links in `README.md` and `docs/**`.

## Related

- `docs/runtime/lifecycle-scripts.md`
- `docs/operations/runbook-production.md`
- `docs/contributing/documentation-standards.md`

## Last Review

- Date: February 21, 2026
- Owner role: Platform Operator
