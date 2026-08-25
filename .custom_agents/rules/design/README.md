---
last_reviewed: 2026-05-19
---

# Design Rules

Object-oriented design and domain-driven development conventions for new and refactored code. Read the file that matches what you're designing.

## Foundations (apply to all new code)

- [principles.md](principles.md) — core design principles: clarity over cleverness, composition over inheritance, explicit over implicit.
- [solid.md](solid.md) — SOLID principles, with deep coverage of the common SRP misconception.
- [anti_patterns.md](anti_patterns.md) — patterns we explicitly forbid (utility classes, repository pattern over AR, passing class names + IDs).
- [refactoring.md](refactoring.md) — when and how to refactor; common refactorings; guidance for when you're unsure.
- [testability_signals.md](testability_signals.md) — testability friction as a design signal; silent side effects, wrong-class ownership, compound operations.

## Patterns (apply when designing that kind of class)

- [service_objects.md](service_objects.md) — single-operation classes (`Creator`, `Processor`, etc.) under `app/models/`.
- [query_objects.md](query_objects.md) — encapsulated AR-relation-returning queries.
- [concerns.md](concerns.md) — when (and when not) to extract shared behavior via `ActiveSupport::Concern`.
- [background_job.md](background_job.md) — method contracts for the custom `Processor` job system. See also `../architecture/background_jobs.md` (architecture) and `../style/background_job.md` (implementation style).

## Related rules

- `../architecture/` — where classes live (file/directory structure).
- `../style/` — naming, formatting, layer-specific style.
- `../security/` — security constraints that may shape the design.
