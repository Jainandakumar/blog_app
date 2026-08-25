---
last_reviewed: 2026-08-19
---

# Advisory findings — judgment calls, kept separate from defects

Used only by the **Feature-level review pipeline**
(`./skills/code-review/feature_review_instructions.md`). The
per-ticket review (`./agents/code_review.md`) does **not** use this file —
its "What NOT to Comment On" rules in
[review_criteria.md](review_criteria.md) stay unchanged: no speculation on
a single ticket's diff.

The Feature-level review is different in kind. It runs once, at the end,
over the whole feature, specifically so a human can decide what to do with
a judgment call before the feature closes. That's worth surfacing — as
long as it never gets mistaken for a confirmed defect.

## Rule

Every finding produced by `feature_review_coverage` or
`feature_review_synthesis` goes into exactly one of two buckets:

- **Known Issues** — concrete, verifiable, would hold up under
  `review_criteria.md`'s bar (a real bug, a real security gap, a real
  requirement that current `develop` does not satisfy).
- **Advisory Findings** — 's judgment call. Plausible, not proven.
  Requires a human decision, not a mechanical fix.

An item never appears in both. Advisory items never contribute to a
blocking/approval determination.

## Categories (Advisory only)

| Category | Bar to include it |
|---|---|
| **Intent vs. documentation gap** | Quote the specific requirement text being second-guessed, and state the reasoning for why the actual goal might differ from what's written. Not "this seems off" — the requirement excerpt plus the inference. |
| **Usability concern** | Tie it to a concrete interaction or flow the code produces. Not "could be nicer." |
| **Inconsistent with similar code** | Name the comparison point — the other file/class this diverges from — so it's falsifiable. |
| **Possible spec/requirement flaw** | Critique of the *requirement itself* (ambiguous, contradictory, or infeasible as written) — separate from critiquing the implementation. Cite the requirement. |

## The dead-code exception

"Implemented but unreachable/never called" is **not automatically
advisory**. If it's verifiably unreferenced anywhere (confirmed by
`grep`/`Grep`, not inferred), that's a concrete defect — file it as a
**Known Issue**. It only belongs here when there's a plausible reason it's
intentionally unwired (feature-toggle staging, work scoped for a later
ticket) and the real question is "is this intentional?" rather than "this
is broken."

## Toggle-coverage gaps are Known Issues, not automatically advisory

A Feature Toggle referenced anywhere in scope but not honored by some
new/changed code (see `review_criteria.md`'s Feature Toggle Coverage
section) is a **Known Issue** by default — distinct from the dead-code
exception above, which concerns code that's unreachable, not code that
runs without checking a toggle it should check. It only moves to Advisory
when the interactive gate (`feature_review_interactive_ux.md`) surfaces
and verifies a concrete reason the omission is intentional and creates no
functional/usability problem — the same bar `review_criteria.md` sets,
applied through this pipeline's existing reclassification mechanism rather
than a new one.

## Output shape

Every advisory item states, in this order:

1. **What  noticed** — the observation.
2. **Why this is advisory, not a confirmed defect** — the reasoning/confidence, and what would need to be true for it to become a real issue.
3. **What this might mean** — the gap or interpretation, in one or two sentences.

A discussion prompt is optional and, when included, is framed as
*"help me evaluate whether X is actually needed"* — never as a fix
instruction. Advisory items don't get a "give this prompt to  to fix
this" box; that box is for Known Issues only, per the report format in
`./agents/feature_review_synthesis.md`.

## Related

- [review_criteria.md](review_criteria.md) — the concrete-findings bar
  this file is the deliberate exception to; unchanged for the per-ticket
  review. Also defines the Feature Toggle Coverage rule the toggle-coverage
  section above applies.
- [feature_review_interactive_ux.md](feature_review_interactive_ux.md) —
  the reclassification mechanism a toggle-coverage downgrade goes through.
- [README.md](README.md) — code-review rules index.
