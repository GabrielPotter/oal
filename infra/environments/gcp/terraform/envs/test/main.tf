# Purpose: Terraform configuration for OAL infrastructure baseline.
# Environment scope: gcp
# Consumer: terraform CLI
# Secret handling: provide sensitive values via TF_VAR_* env vars or secure backend, not hardcoded files.
# Override priority: CLI flags > environment variables > file defaults.
terraform {
  required_version = ">= 1.6.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# NOTE: This is a skeleton composition. Replace placeholder values with real project inputs.
module "network" {
  source = "../../modules/network"
}

module "iam" {
  source = "../../modules/iam"
}

module "gke" {
  source = "../../modules/gke"
}

module "artifact_registry" {
  source = "../../modules/artifact-registry"
}
