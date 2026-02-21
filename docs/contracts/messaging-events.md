# Messaging Event Contracts

## Purpose

Define where and how asynchronous message contracts are documented and versioned.

## Scope

In scope:
- Event contract placement and compatibility expectations.

Out of scope:
- Service-specific event payload business semantics.

## Baseline Assumptions

- Messaging is optional and non-primary.
- Event versioning is explicit and backward compatibility is preferred.

## Contract Location

- Store event contracts under `contracts/messaging/events/`.
- Version event schemas when introducing breaking changes.

## Concrete Commands and Examples

```sh
rg --files contracts/messaging/events
```

## Failure Modes and Troubleshooting

- Consumer breaks on producer update: verify schema compatibility and version handling.

## Related

- `docs/architecture/communication-patterns.md`
- `docs/contracts/http-openapi.md`

## Last Review

- Date: February 21, 2026
- Owner role: Integration Architect
