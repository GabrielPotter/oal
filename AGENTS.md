# AGENTS.md

## Purpose
This document defines how coding agents should contribute to this repository.
The project goal is to build a monorepo hosting a multi-component microservices architecture.
At this stage, business logic is out of scope. The priority is platform skeleton and shared technical foundations.

## Scope
These guidelines apply to:
- All files in this repository.
- Code, config, documentation, and tests changed by an agent.
- Infrastructure, bootstrap scripts, and runtime environment setup.
- Inter-service communication, security, and platform-level conventions.

If a subdirectory later introduces its own `AGENTS.md`, the more specific file takes precedence for that scope.

## Project Priorities
Current implementation focus:
1. Monorepo structure for multiple .NET C# microservices.
2. Reusable service skeletons instead of domain-specific business behavior.
3. Shared communication patterns (sync and async integration foundations).
4. Shared authentication, authorization, and encryption strategy.
5. Runtime environments (local/dev/test/prod style setup) and reproducible scripts.
6. A React + Vite UI subproject integrated into the monorepo.

Platform constraints and defaults:
1. Runtime OS target: Linux-first.
2. Primary relational database: PostgreSQL.
3. Cache: open source Redis (free distribution).
4. Messaging: RabbitMQ support can remain in the codebase, but it is not a primary planned dependency.
5. Deployment target priority: Google Cloud is the first-class cloud target; on-prem remains supported.

Explicitly out of scope for now:
- Deep business rules and feature-specific domain logic.
- Heavy optimization of service internals before platform baseline is stable.

## Agent Workflow
Use this default flow for every task:
1. Read existing repository structure and preserve consistent monorepo conventions.
2. Prefer creating shared building blocks before service-specific duplication.
3. Implement minimal but extensible skeleton components.
4. Ensure security and environment setup are treated as first-class concerns.
5. Validate by running relevant build/test/lint/setup checks.
6. Summarize outcomes and remaining platform gaps.

## Coding Rules
- Prefer small, focused changes over broad refactors.
- Preserve existing style and naming conventions.
- Follow Microsoft/.NET coding conventions for C# code and related project structure by default.
- Use K&R brace style in C# code (opening brace on the same line), for example: `if (condition) { ... }`.
- Do not introduce secrets, credentials, or sensitive data.
- Keep reusable code in shared libraries/modules whenever practical.
- Favor configuration-driven setup over hardcoded environment values.
- Define clear service boundaries and contract-first communication.
- Keep comments concise and only where they add clarity.

## Documentation Format Rules
- Write documentation in English.
- In Markdown command examples, do not prefix script execution with `bash`; use direct executable paths (for example: `infra/lifecycle/run/run-dev.sh up`).
- Use fenced code blocks with an explicit language tag where applicable (for example: `sh`, `yaml`, `json`).

Technology baseline:
- Backend: .NET / C#.
- Frontend: React + Vite + TypeScript.
- UI form factor: always web application (no native/mobile-first UI target in this repository baseline).
- Cross-cutting platform concerns (authn, authz, encryption, communication) should be designed for reuse across services.
- OS/runtime baseline: Linux containers and Linux-hosted workloads.
- Data baseline: PostgreSQL + Redis OSS.
- Cloud baseline: Google Cloud first, on-prem compatibility required.

## Validation
After making changes, run the most relevant available checks, for example:
- `.NET` restore/build/tests for impacted projects.
- Frontend install/build/lint checks for React/Vite project.
- Verification of environment/bootstrap scripts (non-destructive execution where possible).
- Basic validation that service skeletons and shared components are wired consistently.

When project commands are not fully defined yet, validate at minimum by:
- Confirming changed files are present and readable.
- Confirming structure and scripts are internally consistent.
- Confirming docs reflect the current bootstrap approach.

## PR/Change Notes
For each completed task, provide a short summary including:
- What was changed.
- Why the change was needed.
- What was validated and the outcome.
- Which shared platform concerns were covered (communication, authn/authz, encryption, runtime setup).
- Known limitations, assumptions, and suggested next platform steps.
