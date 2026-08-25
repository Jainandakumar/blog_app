---
universal: true
last_reviewed: 2026-05-21
---

# Cross-references — navigating code ↔ docs

How an agent **follows** the link from a piece of code to its feature
documentation, and from a feature doc to the code it describes. This file
is navigation-only — the authoring rules (when to write `@see`, when to
write `paths:`, how to verify the bidirectional link) live in
[`../yard/cross_references.md`](../yard/cross_references.md) and are read
by code-authoring agents and `/document`.

---

## The bidirectional link

A piece of feature code and its feature doc point at each other:

- **Code → doc.** A class header carries a YARD `@see` tag pointing at the feature doc.
- **Doc → code.** A feature doc's frontmatter carries a `paths:` glob covering the code.

Both directions are required. One direction alone leaves the agent guessing.

---

## How to follow links

### When reading code

1. Open the class header. If it has `@see docs/features/...`, follow that link first.
2. If `@see` is missing (legacy code without a feature doc yet), grep `docs/features/**/*.md` for the file path in `paths:` frontmatter.
3. If nothing matches, the feature has no doc yet — note this and proceed without it.

### When reading a feature doc

1. The `paths:` frontmatter is the canonical list of code locations.
2. The "Code entry points" section in the doc body names the canonical classes.
3. Subtopic files have narrower `paths:` covering only the subtopic's code.

---

## Related rules

- Authoring `@see` and `paths:` (when, how, the bidirectional check) — [`../yard/cross_references.md`](../yard/cross_references.md).
- Full YARD syntax (`@param`, `@return`, etc.) — [`../yard/`](../yard/) (folder).
- Feature-doc structure — [`instruction_authoring.md`](instruction_authoring.md).
- Rules-to-code auto-attach — [`instruction_authoring.md`](instruction_authoring.md) §5 Mode C.
