---
last_reviewed: 2026-08-18
---

# Session continuity — `/research` never ends

`/research` is one bounded workflow (bootstrap → build/verify `topic_index.md`
→ present it) followed by a refinement loop that never assumes a final step.
This file is what `SKILL.md`'s closing instruction and `pipelines/answer.md`
point at instead of restating it.

## No retyping `/research`

Once bootstrap (or a resumed session) hands off to `pipelines/answer.md`, treat
every further plain-chat turn in the same conversation as another invocation
of that procedure — consult `topic_index.md`, launch `research_answer.md`,
append `qa_log.md`, present the answer, and stay open. The user should never
need to type `/research` again mid-conversation to ask a follow-up.

This holds until the conversation itself ends. A genuinely new session (new
`` invocation, days later) re-runs `SKILL.md`, which finds
`STATE_research.md` already present and — per
[`../planning/run_state.md`](../planning/run_state.md) — resumes through the
trust/verify check rather than rebuilding from scratch.

## "Write this up" is just another question

Nothing in `/research` is a "compile" or "finalize" step distinct from
answering. A request like "write this up" or "summarize what we found" is a
question like any other: `pipelines/answer.md` answers it the same way,
producing a compile-flavored pass over `topic_index.md` and `qa_log.md`
instead of a single-fact lookup. It does not close the session or change what
happens on the next follow-up.

## What this means for the two orchestrator files

- `pipelines/bootstrap.md` is the only numbered, terminating sequence —
  it exists to get `topic_index.md` built once.
- `pipelines/answer.md` has no terminal step. Its last bullet is always
  "present the answer and stay open," not "done."
