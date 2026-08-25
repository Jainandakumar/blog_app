---
last_reviewed: 2026-05-27
---

# YARD rules

Authoring conventions for YARD documentation in Ruby files (`.rb`). Read by
code-authoring agents and the `/document` skill.

## Files

| File | Topic |
|---|---|
| [authoring.md](authoring.md) | When and how to write YARD on classes, modules, methods. Tag set (`@param`, `@return`, `@raise`, `@example`, `@see`). Type formatting. Pronto verification. |
| [cross_references.md](cross_references.md) | When and how to write `@see` tags linking code to feature docs (`docs/features/...`). Authoring rules for the feature-doc `paths:` frontmatter. Bidirectional verification check. |

## When to read this folder

- Writing or modifying a public Ruby method.
- Modifying a class header that may need a `@see` tag.
- Running `/document` (which applies YARD across changed files).

## Scope

YARD rules apply to `.rb` files only, excluding `spec/`, `test/`, and `db/migrate/`.

## Related

- [`../meta/cross_references.md`](../meta/cross_references.md) — Navigation contract (how to *follow* `@see` and `paths:` links when reading; complementary to the *authoring* rules here).
- Pronto cops enforce YARD on the MR diff via `bin/pronto run -c origin/develop`.
