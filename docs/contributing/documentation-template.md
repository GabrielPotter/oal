# Documentation Template

## Purpose

Provide a copy-ready template for new documentation pages.

## Scope

In scope:
- Template structure and mandatory sections.

Out of scope:
- Topic-specific content guidance.

## Baseline Assumptions

- New pages are created only under `docs/**`.

## Template

~~~md
# <Title>

## Purpose

<What this page is for>

## Scope

In scope:
- <item>

Out of scope:
- <item>

## Baseline Assumptions

- <assumption>

## Concrete Commands and Examples

~~~sh
<command>
~~~

## Failure Modes and Troubleshooting

- <failure> -> <resolution>

## Related

- `docs/<path>.md`

## Last Review

- Date: <Month DD, YYYY>
- Owner role: <role>
~~~

## Failure Modes and Troubleshooting

- Missing sections after copy: validate with `infra/lifecycle/verify/verify-docs.sh`.

## Related

- `docs/contributing/documentation-standards.md`

## Last Review

- Date: February 21, 2026
- Owner role: Platform Maintainer
