# Deploy Scripts

Add environment-specific deployment scripts here.

Recommended baseline:

- On-prem HTTPS mode:
  - `docker compose -f infra/docker/compose/docker-compose.onprem-https.yml up --build -d`
- GCP mode:
  - `kubectl apply -k infra/k8s/overlays/prod`
