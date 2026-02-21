# Documentation Standards

## Purpose

Define repository-wide documentation rules for consistency and maintainability.

## Scope

In scope:
- Location rules.
- Required section structure.
- Formatting conventions.

Out of scope:
- Non-markdown code style rules.

## Baseline Assumptions

- Root `README.md` is the entrypoint.
- Detailed docs live under `docs/**`.
- `AGENTS.md` is the governance exception at repository root.

## Required Structure Per Doc Page

Each markdown page under `docs/**` must include:
1. `## Purpose`
2. `## Scope`
3. `## Baseline Assumptions`
4. Concrete commands/examples (when relevant)
5. `## Failure Modes and Troubleshooting`
6. `## Related`
7. `## Last Review`

## Formatting Rules

- English language only.
- Command examples use fenced `sh` blocks.
- Avoid command blocks with `bash` prefix.
- Keep links relative within repository docs.

## Failure Modes and Troubleshooting

- Missing mandatory sections: run `infra/lifecycle/verify/verify-docs.sh`.
- Markdown outside allowed locations: move under `docs/**`.

## Related

- `docs/contributing/documentation-template.md`
- `docs/operations/runbook-ci.md`

## Last Review

- Date: February 21, 2026
- Owner role: Platform Maintainer
