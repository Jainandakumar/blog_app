---
last_reviewed: 2026-08-18
---

# Research rules

Conventions for the `/research` skill — a durable, reusable index of where a
topic's docs/code/YARD live, verified against current files, plus the
refinement loop that answers follow-up questions against that index.

## Files

| File | Topic |
|---|---|
| [session_continuity.md](session_continuity.md) | Why `/research` never models a "final step" — how the Q&A loop stays open across plain-chat turns, and how a "write this up" request is just another (compile-flavored) question. |
| [topic_index_schema.md](topic_index_schema.md) | `topic_index.md`'s frontmatter + table schema, the sharding convention for large topics, and the current-state-only principle that bounds what may be written into it. |
| [findings.md](findings.md) | How `research_answer.md`'s doc/YARD-defect and suspected-bug flags get triaged inline: `doc_review.md`'s checklist format (reused from `feature_docs.md`), `findings.md`'s append-only log, and the ticket-mode/topic-mode ask-the-user split. |

## When to read this folder

- Authoring or updating `research_index.md`, `research_answer.md`, or the
  `/research` skill's pipeline files.
- Reading or writing `topic_index.md`, `qa_log.md`, `doc_review.md`, or
  `findings.md` in any `.workspace/{ticket-or-RESEARCH-slug}/` folder.

## Related

- [`../planning/run_state.md`](../planning/run_state.md) — `CONTEXT.md` /
  `STATE_research.md`, the resume/trust-verify contract `/research` shares
  with every other orchestrator skill.
- [`../planning/workspace_sync.md`](../planning/workspace_sync.md) — the
  `RESEARCH-` local-only sync gate.
- [`../agent_authoring/research_confidence.md`](../agent_authoring/research_confidence.md)
  — the Confirmed/Likely/Uncertain/Unverified vocabulary used throughout.
- [`../documentation/feature_docs.md`](../documentation/feature_docs.md) —
  the `doc_review.md` checklist format `findings.md` (this folder) reuses.
