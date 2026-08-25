---
last_reviewed: 2026-08-18
---

# `topic_index.md` schema

The growing index `research_index.md` builds and verifies, and
`research_answer.md` consults and touches up. One per
`.workspace/{ticket-or-RESEARCH-slug}/`.

## Format

```yaml
---
topic: "HSA spending accounts"
topic_slug: hsa_spending_accounts
ticket_key: RESEARCH-hsa_spending_accounts   # or the real MDP-#### in ticket-mode
aliases: []
built_at: 2026-08-18T14:02:00Z
last_updated_at: 2026-08-18T15:47:00Z
---

## Docs
| Doc | Section | Confidence | Last Verified | Notes |

## Code
| File | Class/Symbol | Relevance | Confidence | Last Verified | Notes |

## YARD-documented symbols
| Symbol | File | @see target | Confidence | Last Verified |

## Open questions / gaps
## Related topics
```

- **`aliases`** — alternate phrasings the topic might be asked under (helps
  `pipelines/answer.md`'s row-matching on later questions).
- **Confidence** — `research_confidence.md`'s Confirmed / Likely / Uncertain /
  Unverified vocabulary, not restated here.
- **Last Verified** — ISO-8601 timestamp, stamped whenever a row is built,
  re-checked, or touched up (by either `research_index.md` or
  `research_answer.md`).
- **Open questions / gaps** — things the walk couldn't resolve (no doc found,
  conflicting sources, a symbol with no `@see`).
- **Related topics** — other `topic_slug`s worth cross-referencing, not full
  duplication of their rows.

## Sharding for large topics

Borrowed directly from `feature_docs.md`'s already-validated splitting
pattern: once a topic's rows grow past a soft size nudge, split by natural
subtopic into `index/{subtopic}.md` (same table shape as above, scoped to
that subtopic) and reduce `topic_index.md` itself to a table of contents
linking each `index/{subtopic}.md`. Conservative and per-run — don't
restructure existing shards just to rebalance them.

## Principle: describes current codebase state only

Every row in this file — and every claim in `qa_log.md` — must reflect what
currently exists and behaves, verified against actual files. Never planned,
proposed, or pre-development content. This bounds how ticket-mode folds in
other skills' output when building or verifying rows:

- `jira_context.md` / `feature_context.md` (ticket description, acceptance
  criteria, "Safe Update Strategy") is requirements/planning data. It scopes
  *what domain to walk* — it is never copied into a row as if it were a
  verified fact about the codebase.
- `research.md`'s `## Recommendations` section (and anything similarly
  forward-looking in `spike_report.md`, `breakdown.md`, brief files) is
  excluded when folding that file in as a source. Only its descriptive
  sections (`Relevant Files`, `Patterns Found`, `Reusable Code`) qualify as
  "what is."
- If an in-flight ticket would change what a row says, that's separate,
  explicitly-labeled context ("MDP-1234 proposes changing this — not yet
  implemented") in the Notes column — never blended into the row as current
  fact.
- `findings.md` and `doc_review.md` (see
  [`findings.md`](findings.md) in this folder) stay consistent with this by
  construction — both describe a mismatch involving current reality, not a
  proposal.

## Related

- [`../agent_authoring/research_confidence.md`](../agent_authoring/research_confidence.md)
  — confidence vocabulary.
- [`../yard/cross_references.md`](../yard/cross_references.md) — the `@see` /
  `paths:` walk that populates the Docs/Code/YARD sections.
- [`../documentation/feature_docs.md`](../documentation/feature_docs.md) —
  the sharding pattern this borrows from.
