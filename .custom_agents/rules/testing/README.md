---
last_reviewed: 2026-05-19
---

# Testing rules

Standards, patterns, and requirements for writing tests in this codebase. RSpec is the primary framework; Minitest is legacy.

For where test files physically live in the repo (directory structure, naming, the `spec/` vs `test/` split), see [`../architecture/tests.md`](../architecture/tests.md). The rules below cover *how to write* tests, not *where they go*.

## Topics

### Foundations (read first)

- [`philosophy.md`](philosophy.md) — What tests document, what to test, what NOT to test. The "guarantees we commit to" mental model.
- [`requirements.md`](requirements.md) — Mandatory rules: all tests in `spec/`, all new code has tests, coverage targets, never rewrite tests to make them pass.
- [`rspec.md`](rspec.md) — RSpec is the primary framework; Minitest is legacy. Basic spec layout.

### Writing tests

- [`test_types.md`](test_types.md) — Unit, request, feature/system, and (legacy) controller specs — when to use each.
- [`structure.md`](structure.md) — `describe`/`context`/`it` organization, `let`/`let!` patterns, one-assertion-per-test, style guidelines.
- [`factories.md`](factories.md) — FactoryBot for test data; fixtures only for static reference data.
- [`test_objects.md`](test_objects.md) — Preference hierarchy: real/factory objects > test doubles > mocks/stubs. Detroit-school TDD.

### Operations

- [`running.md`](running.md) — Targeted RSpec runs, `bin/rspec-changed`, why you should NOT run the full suite locally.
- [`common_patterns.md`](common_patterns.md) — Validations, associations, scopes, callbacks, services, API endpoints, background jobs.

## When to read what

- **Writing a new spec from scratch:** philosophy → requirements → rspec → test_types → structure → factories → test_objects.
- **Picking the right test type:** test_types.
- **Test failing in CI:** requirements (§Never Rewrite Tests) → running.
- **Need a copy-paste template:** common_patterns.
- **Wondering whether to mock or use a factory:** test_objects.
