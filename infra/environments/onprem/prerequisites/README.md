# On-Prem Prerequisites

Install baseline host dependencies before running on-prem scripts.

- Ubuntu packages: `packages.ubuntu.txt`
- RHEL packages: `packages.rhel.txt`
- Required runtime/deploy toolchain: `docker`, `docker compose`, `kubectl`, `kustomize`
- Additional on-prem edge tools: `openssl`, `certbot`, `nginx`

Interactive check/install:

`infra/lifecycle/prerequisites/check-install.sh --target onprem`

The checker reports to `/tmp/oal-prereq-report.json`.
