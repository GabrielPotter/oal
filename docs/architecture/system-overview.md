# System Overview

## Purpose

Describe the reusable platform shape provided by this repository.

## Scope

In scope:
- Shared runtime model and deployment targets.
- Request flow and edge boundaries.

Out of scope:
- Domain-specific service behaviors.

## Baseline Assumptions

- Linux-first services and containers.
- PostgreSQL + Redis OSS as data baseline.
- RabbitMQ optional, not primary.
- Primary cloud target is GCP, on-prem stays supported.

## Core Topology

Request flow:

Browser -> Nginx (web static + reverse proxy) -> Gateway.Api -> internal services

Rules:
- `Gateway.Api` is the only user-facing backend.
- Internal services are private network targets.
- User traffic is HTTPS at edge.
- Internal service traffic may be HTTP inside private boundaries.

## Failure Modes and Troubleshooting

- Browser cannot load UI: verify Nginx is running and mapped to expected host/port.
- API 502/504 at edge: verify Gateway health and upstream routing.
- Internal service unreachable: verify private network and service discovery.

## Related

- `docs/architecture/service-boundaries.md`
- `docs/architecture/communication-patterns.md`
- `docs/security/encryption.md`

## Last Review

- Date: February 21, 2026
- Owner role: Platform Architect
