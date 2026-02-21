# GCP GKE Module (Skeleton)

Creates a regional GKE cluster and node pools for OAL services.

Expected inputs:
- VPC and subnet IDs
- Service account identity
- Workload Identity settings

Expected outputs:
- `cluster_name`
- `cluster_endpoint`
- `workload_identity_pool`
