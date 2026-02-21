#!/usr/bin/env bash
# Purpose: Run terraform init/plan/apply for selected GCP environment.
# Inputs:
#   --env {dev|test|prod}
#   - TF_VAR_* variables via environment
# Examples:
#   bash infra/environments/gcp/scripts/deploy/terraform-apply.sh --env dev
#   TF_VAR_project_id=my-project bash infra/environments/gcp/scripts/deploy/terraform-apply.sh --env prod
set -euo pipefail

ENV_NAME=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --env) ENV_NAME="$2"; shift 2 ;;
    *) echo "Unknown argument: $1"; exit 2 ;;
  esac
done

if [[ -z "$ENV_NAME" ]]; then
  echo "Missing --env {dev|test|prod}"
  exit 2
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../.." && pwd)"
TF_DIR="$ROOT_DIR/infra/environments/gcp/terraform/envs/$ENV_NAME"

if [[ ! -d "$TF_DIR" ]]; then
  echo "Terraform env directory not found: $TF_DIR"
  exit 1
fi

pushd "$TF_DIR" >/dev/null
terraform init
terraform plan -out=tfplan
terraform apply -auto-approve tfplan
popd >/dev/null
