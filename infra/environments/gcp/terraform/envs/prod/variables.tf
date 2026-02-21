# Purpose: Terraform configuration for OAL infrastructure baseline.
# Environment scope: gcp
# Consumer: terraform CLI
# Secret handling: provide sensitive values via TF_VAR_* env vars or secure backend, not hardcoded files.
# Override priority: CLI flags > environment variables > file defaults.
variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region for shared resources"
  type        = string
  default     = "us-central1"
}
