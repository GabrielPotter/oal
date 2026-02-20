# System Overview

## Purpose

This repository is a reusable microservices platform skeleton for new product teams.
The main objective is to provide shared runtime, security, communication, and environment automation so new projects can focus on business logic and API contracts.

## Runtime and Infrastructure Baseline

- Runtime target: Linux-first services and containers.
- Primary relational data store: PostgreSQL.
- Primary cache: Redis OSS.
- Messaging capability: RabbitMQ can be used, but it is optional and not a primary dependency.

## Deployment Targets

- Primary cloud target: Google Cloud.
- Secondary target: on-premises environments.
- All infrastructure and scripts should keep both targets deployable with minimal environment-specific overrides.

## Request Flow

Browser -> Nginx (web static + reverse proxy) -> Gateway.Api (frontend microservice/BFF) -> internal services.

- Users never call internal services directly.
- `Gateway.Api` is the single user-facing backend entrypoint.
- Internal service endpoints are private network targets in container/cloud deployments.
- TLS is terminated at edge (Nginx/Ingress/LB), user traffic is always HTTPS.
- Internal service communication is HTTP inside private network boundaries.
