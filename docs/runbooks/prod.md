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
- Bootstrap helper: `infra/environments/onprem/scripts/tls/issue-letsencrypt.sh`.
- Renewal helper: `infra/environments/onprem/scripts/tls/renew.sh`.
- Cert paths expected by Nginx:
  - `/etc/letsencrypt/live/<domain>/fullchain.pem`
  - `/etc/letsencrypt/live/<domain>/privkey.pem`

## GCP TLS Lifecycle

- External HTTPS load balancing handled by GKE Ingress + `ManagedCertificate`.
- Environment overlays:
  - `infra/environments/gcp/k8s/overlays/dev`
  - `infra/environments/gcp/k8s/overlays/test`
  - `infra/environments/gcp/k8s/overlays/prod`

## On-Prem Kubernetes Lifecycle

- On-prem ingress and TLS overlays:
  - `infra/environments/onprem/k8s/overlays/dev`
  - `infra/environments/onprem/k8s/overlays/test`
  - `infra/environments/onprem/k8s/overlays/prod`
- Runtime secret interface and deployment prerequisites:
  - `infra/environments/onprem/README.md`
  - `infra/environments/onprem/manifests/runtime-secrets.example.yaml`
- Hardened VM/container bootstrap profile:
  - `infra/environments/onprem/docker/compose/stack.hardened.yml`
