---
last_reviewed: 2026-07-15
---

# Feature documentation (`docs/features/`)

How to author, verify, and maintain **feature documentation** — the
plain-language, code-adjacent description of what each area of the application
does. Read by the `document_feature` agent, which both `/document` and
`/develop` launch. Feature documentation is authored **together with YARD** in
one documentation pass (see "Working with YARD").

## Vocabulary

- **Functional Area** — the top-level unit. Its slug (the normalized Jira
  **Functional Area** value) names the top-level doc:
  `docs/features/{functional_area}.md`.
- **detail doc** — a finer topic within a Functional Area:
  `docs/features/{functional_area}/{detail}.md`. No Jira field; created only
  when the Functional Area doc grows too large (see "Splitting").
- **"Feature" is Jira-only.** The docs practice is *feature documentation*; it
  is not the Jira "Feature" ticket type. Never write bare "Feature" for a doc.

## The anchor: Functional Area

The Jira **Functional Area** field (returned as `functional_area` by
`mcp__jira__get_issue`, present on Initiative / Feature / Story) is the
authoritative signal for *where* documentation goes.

1. **Slug** = the value normalized to snake_case: `"Technical Infrastructure"`
   → `technical_infrastructure`.
2. **Target** = `docs/features/{slug}.md` (and its `{slug}/` detail docs).
3. **Precedence** — the **User Story's** Functional Area is the doc target; the
   Feature / Initiative values are context. If they differ across levels, read
   the existing docs in *both* areas and decide where the content belongs (it
   may land in more than one place). Record the decision in your return; when
   content lands in more than one area, log a `cross-area` item to
   `doc_review.md` (see *Deferred work*) for later reconciliation.
4. **No Functional Area** (e.g. `LOCAL-`, or the field is empty) — fall back to
   the `paths:` glob match against existing docs. If none matches, **flag the
   gap; do not guess** a slug.

## Verify-or-enhance (not "always add")

Every run verifies the relevant doc is still accurate for the change and
enhances only what the change touched. **Most changes are a no-op** — say so
and move on.

- **Update when:** an entry-point class's public method signature changed; a
  new entry-point class was added for the area; a class was renamed or deleted;
  the described lifecycle / behavior structurally changed.
- **No-op when:** private-only refactor, test-only changes, or style/whitespace.

The goal is documentation that is *well-written with only the applicable
details* — not more documentation.

## Bootstrapping a new Functional Area doc

When no `docs/features/{slug}.md` exists **and** the ticket has a parent
Feature / Initiative: create a base doc from their high-level description (the
Initiative is the authoritative functional spec — use the Initiative context in
the workspace). For tickets with **no** Feature / Initiative anchor
(Bug / Task / `LOCAL-` with no parent), **flag the gap; do not create** — this
avoids shallow-doc spam.

## Splitting (conservative, per run)

Keep each doc focused. When a Functional Area doc grows past a **soft
~200–300-line nudge** *and* there is one obvious cohesive chunk to lift out,
extract that chunk into `docs/features/{slug}/{detail}.md`. `{detail}` is
snake_case, named from the dominant class/concept; **prefer appending to an
existing detail doc over creating a near-duplicate.**

**Do not** attempt larger restructuring in a per-ticket run — merging docs,
re-splitting, moving content across multiple detail docs, or rewrites. Log
them to `doc_review.md` (see *Deferred work*) and move on.
Naming/structure churn is safe because the code↔doc binding is path-based
(`@see` / `paths:`), not name-based.

## Cross-references

- **Doc ↔ code** — via `@see` (in code) ↔ `paths:` (in the doc), per
  [`../yard/cross_references.md`](../yard/cross_references.md). Many-to-many: a
  class may be covered by more than one Functional Area doc.
- **Doc ↔ ticket** — record the Initiative / Feature keys the doc derives from
  (frontmatter or a short "References" line).
- **Feature docs do NOT cross-reference each other** merely because they share a
  class. Link another area's doc only when it genuinely aids understanding.
- **Don't duplicate YARD.** A short high-level behavior summary is good; do not
  restate per-method contracts — cross-reference the code instead.

## Working with YARD (one documentation pass)

Feature docs and YARD are authored **together** so the bidirectional link is
consistent in a single pass:

1. `document_feature` authors / verifies the Functional Area doc(s) and sets
   each doc's `paths:`.
2. `document_yard` verifies / completes YARD on the changed code and wires each
   entry-point class's `@see` to the now-current feature doc.

Both `/document` and `/develop` run these two agents together — feature docs
first, then YARD. See [`../yard/README.md`](../yard/README.md).

## Frontmatter

Per [`../meta/frontmatter_specs.md`](../meta/frontmatter_specs.md). Keep the
existing field names: `feature:` on the top-level doc holds the **Functional
Area slug**; `parent_feature:` on a detail doc holds the parent slug.

## Merge conflicts (parallel Stories, same area)

Two Stories under one Feature can both edit `docs/features/{slug}.md`. Resolve
**additively**: keep both sides' content, apply the well-written bar, remove
only true duplication. If the combined result needs real restructuring, do the
minimal safe merge and log a `reorg` item to `doc_review.md` (see *Deferred
work*).

## Deferred work → `doc_review.md`

Structural work this pass must **not** do (splits, merges, rewrites, cross-area
reconciliation) is logged as a **checklist** in the ticket's workspace, for the
consistency-review skill (`/doc-review`, planned) to process later — not left
in the run summary, not inline in the docs.

- **File:** `.workspace/{ticket}/doc_review.md` — one per ticket (no
  cross-ticket name collisions; deterministic to sync; sits alongside the
  ticket's other artifacts).
- **Checklist format** (status is tracked, so use checkboxes):

  ```
  # Doc review — {TICKET}

  - [ ] **{functional_area}** — {type}: {what and why} → docs/features/{path}
  ```

  `{type}` ∈ `split` (doc too large) · `cross-area` (content spans/overlaps
  another area) · `drift-check` (shared code changed; another area's doc may be
  stale) · `reorg` (needs multi-doc restructuring).
- **Append** open items as encountered; skip an identical open item; leave
  existing checked (`- [x]`) items alone.
- **Consumer:** `/doc-review` gathers every ticket's `doc_review.md`, groups by
  area, processes, and **checks items off** (`- [x]`) as it resolves them —
  preserving status/history, never blind-deleting. Workspace sync keeps the
  checklist current in the remote across updates.

## Related

- [`../yard/cross_references.md`](../yard/cross_references.md) — `@see` ↔ `paths:` authoring + the bidirectional check.
- [`../meta/cross_references.md`](../meta/cross_references.md) — following code↔doc links when reading.
- [`../meta/frontmatter_specs.md`](../meta/frontmatter_specs.md) — feature-doc frontmatter schema.
- [`../planning/tech_design.md`](../planning/tech_design.md) — design docs that may seed a Functional Area doc.
