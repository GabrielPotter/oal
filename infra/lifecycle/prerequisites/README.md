# Lifecycle: Prerequisites

This stage validates and optionally installs required tools by target profile.

Profiles are intentionally aligned for runtime parity:
- `dev` and `onprem` both require container + Kubernetes toolchains.
- `onprem` additionally requires TLS/edge host tools.
- `dev` uses `kind` as the local cluster runtime.

## Command

```bash
infra/lifecycle/prerequisites/check-install.sh --target {dev|onprem|gcp} --mode {interactive|check-only}
```

## Ubuntu 24.04 full dev bootstrap

If you want a guided install/upgrade script for a developer workstation (interactive per missing tool):

```bash
infra/lifecycle/prerequisites/install-dev-ubuntu24.sh
```

## Outputs

- Human-readable report in terminal.
- Machine-readable JSON report: `/tmp/oal-prereq-report.json`.
