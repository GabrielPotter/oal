# Lifecycle: Deploy

Full deployment pipelines for production targets.

## On-prem

`infra/lifecycle/deploy/deploy-onprem.sh --env {dev|test|prod} --mode {compose-hardened|k8s}`

## GCP

`REGISTRY_PREFIX=<registry> infra/lifecycle/deploy/deploy-gcp.sh --env {dev|test|prod}`

## Notes

- On-prem pipeline creates a release bundle before deployment.
- GCP pipeline performs build/push/terraform/apply in sequence.
