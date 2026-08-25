---
last_reviewed: 2026-07-16
---

# Documentation rules

Conventions for authoring the repository's prose documentation layers (as
distinct from YARD code-level docs, which live in [`../yard/`](../yard/)).

## Files

| File | Topic |
|---|---|
| [feature_docs.md](feature_docs.md) | Authoring / verifying **feature documentation** under `docs/features/`, anchored by Jira Functional Area; the two-tier `{functional_area}.md` / `{functional_area}/{detail}.md` structure; verify-or-enhance rubric; the `doc_review.md` deferred-work checklist. |

## When to read this folder

- Authoring or updating the `document_feature` agent.
- Running `/document` or the `/develop` post-Code documentation action.

## Related

- [`../yard/README.md`](../yard/README.md) — YARD (code-level docs); feature
  docs and YARD are authored together in one pass (`document_feature` then
  `document_yard`).
- [`../meta/cross_references.md`](../meta/cross_references.md) — following
  `@see` ↔ `paths:` links when reading.
- [`../meta/frontmatter_specs.md`](../meta/frontmatter_specs.md) — feature-doc
  frontmatter schema.
