---
paths:
  - "lib/**"
last_reviewed: 2026-05-19
---

# The lib/ Directory

Why `lib/` is legacy and where new code should go instead.

---

## Do Not Add New Code Here

The `lib/` directory has become a legacy dumping ground with bi-directional dependencies. **99.999% sure NO new code should go here.**

**Exception:** Background job classes (`Job*` inheriting from `Processor`) go in `lib/job_*.rb`. See [`background_jobs.md`](background_jobs.md).

---

## Current Reality

- Contains old domain logic that should be in `app/models/`
- Has bi-directional dependencies (code depends on code that depends on it)
- Contains integration libraries and utilities mixed with business logic
- Code must be explicitly loaded via `config/application.rb`
- Difficult to extract or refactor

---

## Key Existing Areas (Reference Only)

When editing existing code, you may encounter:

| Directory | Content |
|-----------|---------|
| `lib/enrollment/` | Legacy enrollment domain logic (should be in `app/`) |
| `lib/aca_*/` | ACA-related modules |
| `lib/integrations/` | External system integrations |
| `lib/exports/`, `lib/imports/` | Data exchange |
| `lib/marshal/` | EDI file processing |
| `lib/reports/` | Report generation |

---

## When You Must Touch lib/

If fixing a bug or extending existing `lib/` code:
- Make your change following current patterns in that file
- Don't refactor the entire file unless explicitly requested
- Consider creating a tech debt ticket for future migration to `app/models/`
