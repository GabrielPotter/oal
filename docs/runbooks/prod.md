# Production Runbook

## Target Environments

- Primary cloud deployment target: Google Cloud.
- Secondary deployment target: on-premises infrastructure.

## Production Baseline Requirements

- Linux-based runtime for services.
- PostgreSQL as primary relational database.
- Redis OSS as primary cache.
- RabbitMQ only when explicitly required by a service design.

## Operational Notes

- Environment-specific values must come from configuration and secret stores, not hardcoded values.
- Infrastructure definitions should prefer shared modules with environment overlays for GCP and on-prem.

## HTTPS and TLS Policy

- User-facing traffic must be HTTPS only.
- HTTP (port 80) must redirect to HTTPS (301/308).
- Internal service-to-service traffic may stay HTTP on private network boundaries.

## On-Prem TLS Lifecycle

- Certificate source: Let's Encrypt (DNS/HTTP challenge).
- Bootstrap helper: `infra/scripts/init/tls-onprem.sh`.
- Renewal helper: `infra/scripts/env/tls-renew.sh`.
- Cert paths expected by Nginx:
  - `/etc/letsencrypt/live/<domain>/fullchain.pem`
  - `/etc/letsencrypt/live/<domain>/privkey.pem`

## GCP TLS Lifecycle

- External HTTPS load balancing handled by GKE Ingress + `ManagedCertificate`.
- Base manifests:
  - `infra/k8s/base/managed-certificate.yaml`
  - `infra/k8s/base/ingress.yaml`
- Environment overlays:
  - `infra/k8s/overlays/dev`
  - `infra/k8s/overlays/test`
  - `infra/k8s/overlays/prod`
