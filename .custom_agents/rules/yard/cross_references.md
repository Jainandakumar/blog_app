---
paths:
  - "**/*.rb"
  - "docs/features/**"
last_reviewed: 2026-05-21
---

# YARD cross-references — `@see` and `paths:`

When code is part of a feature with documentation under `docs/features/`, the
class header carries a `@see` tag pointing at the feature doc, and the feature
doc's `paths:` frontmatter covers the code. This file describes when and how
to author both directions, and how to verify them.

For *how to follow* an existing link when reading code or a feature doc, see
[`../meta/cross_references.md`](../meta/cross_references.md).

---

## Code → doc (YARD `@see`)

### Format

```ruby
# Coerces import-row attribute values to the column types declared by the file
# type definition.
#
# @see docs/features/imports/typecasting.md Imports typecasting subtopic
class Imports::Typecaster
  # ...
end
```

### Rules

- **Path is repo-relative**, no leading `./`.
- **Trailing description is required.** YARD's `@see` tag is built for Ruby
  code references and URLs; without a description, YARD renders the relative
  path twice in its HTML output. Keep the description short (3-6 words naming
  the doc): "Imports feature documentation", "Batch demographic import
  subtopic", etc.
- **One `@see` per class header is enough**; methods inherit it.
- A method may add its own `@see` if it cross-cuts into a different feature.
- **Point at the most specific subtopic** file when one exists; otherwise the
  top-level feature file.

---

## Doc → code (frontmatter `paths:`)

### Format

```yaml
---
feature: imports
paths:
  - app/models/imports/**
  - lib/job_import_*.rb
  - components/imports/**
---
```

### Rules

- Globs cover wherever the feature's code lives, regardless of top-level
  directory (engines, components, lib).
- Globs are matched against repo-relative paths. Test before committing.
- Top-level feature docs list all paths covering the feature; subtopic files
  list narrower paths covering only the subtopic's code.

---

## Bidirectional verification

When modifying an entry-point class, verify both directions still match:

1. If the class header has `@see docs/features/<path>`, open that doc and
   confirm `paths:` covers the class's file.
2. If the class's file matches a feature doc's `paths:` glob, confirm the
   class header has a corresponding `@see` tag pointing at that doc (or at
   a more specific subtopic doc when one exists).
3. When **introducing** a new entry-point class for an existing feature, add
   `@see` to the class header. Do not auto-create new feature docs when no
   doc exists — flag the gap and move on.
4. When **removing or renaming** an entry-point class, update both directions:
   the `@see` references (in code) and the `paths:` globs (in feature docs).

---

## Related

- [authoring.md](authoring.md) — Full YARD tag set and authoring rules.
- [`../meta/cross_references.md`](../meta/cross_references.md) — How to *follow* `@see` and `paths:` links when reading code or feature docs.
- [`../meta/frontmatter_specs.md`](../meta/frontmatter_specs.md) — Feature-doc frontmatter schema (the `paths:` field).
