# Lifecycle Scripts

## Purpose

Provide a single operational reference for prerequisites, build, run, deploy, and verify scripts.

## Scope

In scope:
- Script entrypoints under `infra/lifecycle`.
- Target-specific prerequisites and validation.

Out of scope:
- Script implementation internals.

## Baseline Assumptions

- `dev` and `onprem` are tooling-parity oriented.
- `gcp` adds cloud-specific prerequisites.

## Prerequisites

Profile check/install:

```sh
infra/lifecycle/prerequisites/check-install.sh --target {dev|onprem|gcp} --mode {interactive|check-only}
```

Ubuntu 24.04 guided dev bootstrap:

```sh
infra/lifecycle/prerequisites/install-dev-ubuntu24.sh
```

## Build

```sh
infra/lifecycle/build/build-all.sh --target {dev|onprem|gcp} --env {dev|test|prod}
```

## Run

```sh
infra/lifecycle/run/run-dev.sh [up|down|reset]
infra/lifecycle/run/run-onprem.sh [bootstrap|hardened|down]
infra/lifecycle/run/run-gcp.sh --base-url <url>
```

## Deploy

```sh
infra/lifecycle/deploy/deploy-onprem.sh --env {dev|test|prod} --mode {compose-hardened|k8s}
REGISTRY_PREFIX=<registry> infra/lifecycle/deploy/deploy-gcp.sh --env {dev|test|prod}
```

## Verify

```sh
infra/lifecycle/verify/verify-all.sh --target {dev|onprem|gcp|all}
infra/lifecycle/verify/verify-docs.sh
```

## Failure Modes and Troubleshooting

- Missing tools: run `check-install.sh` in `check-only` mode first.
- Invalid manifests: use target-specific verify scripts to isolate failures.

## Related

- `docs/runtime/environments.md`
- `docs/operations/runbook-ci.md`
- `docs/operations/runbook-local-dev.md`

## Last Review

- Date: February 21, 2026
- Owner role: Platform Maintainer
