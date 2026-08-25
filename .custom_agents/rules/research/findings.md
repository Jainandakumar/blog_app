---
last_reviewed: 2026-08-18
---

# Finding triage — doc defects and suspected bugs

`research_answer.md` verifies against current files before answering; when
that verification surfaces a doc/YARD defect or a suspected code bug, it
returns a structured flag rather than writing the log itself (its `Write`
scope is limited to `qa_log.md` and `topic_index.md` row touch-ups). Logging
and any user ask happen in `pipelines/answer.md`, which runs in the
orchestrator's own context. This is v1 scope — full inline workflow, not
deferred to a future pass.

## Doc / YARD staleness → `doc_review.md`

Reuse `feature_docs.md`'s existing checklist format **verbatim** — this is
the same consumer the not-yet-built `/doc-review` skill will read, so don't
invent a second format:

```
- [ ] **{functional_area}** — {type}: {what and why} → docs/features/{path}
```

`{type}` is one of `feature_docs.md`'s existing four values. A defect found
during `/research` (rather than during a code change) is almost always
`drift-check` — "shared code changed; another area's doc may be stale" reads
naturally as "research found this doc no longer matches current code."
Use `split` / `cross-area` / `reorg` only if the finding is genuinely that
shape.

Append to `[workspace]/doc_review.md`; skip an identical open item; never
touch existing checked (`- [x]`) items.

## Suspected bug / other substantive finding → `findings.md`

Append-only, one entry per finding:

```
## Finding — {ISO-8601 timestamp}
**Area:** {file/class or symbol}
**What:** {the suspected bug or discrepancy, in plain language}
**Evidence:** {file path(s)/line, or the specific behavior observed}
**Status:** logged | ticket created ({TICKET_KEY})
```

- **Ticket-mode:** just log it — the developer is already engaged with the
  ticket and will triage it themselves.
- **Topic-mode:** ask the user right then, via `AskUserQuestion` —
  "Create a ticket for this finding?" (`Create ticket` / `Skip`) — reusing
  `./agents/planning_jira_create.md` as-is. Repeat this ask each time a
  new, distinct finding surfaces; never batch findings for "the end" (that
  would violate session continuity — there is no "the end").

### Parenting a ticket created from topic-mode

`planning_jira_create.md` always creates under a parent Feature
(`parent_key`). A topic-mode `RESEARCH-` workspace has no Jira ticket of its
own to supply one. Before launching it, ask the user which Feature to parent
the new ticket under (or confirm there isn't one, if the project allows a
top-level Bug) — don't guess a `parent_key`.

On `Create ticket`, update the `findings.md` entry's `Status` line to
`ticket created ({TICKET_KEY})` rather than appending a second entry.

## Related

- [`../documentation/feature_docs.md`](../documentation/feature_docs.md) —
  the `doc_review.md` checklist format and its `{type}` values.
- [`../../agents/planning_jira_create.md`](../../agents/planning_jira_create.md)
  — reused as-is for the topic-mode ticket offer.
- [`topic_index_schema.md`](topic_index_schema.md) — the current-state-only
  principle both `doc_review.md` and `findings.md` entries stay consistent
  with by construction.
