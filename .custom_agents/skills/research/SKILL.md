---
name: research
description: Build a verified index of where a topic's (or Jira ticket's) docs, code, and YARD live, then answer follow-up questions against it in the same session — re-verifying against current files each time. Use `/research <topic>` or `/research <TICKET-KEY>`.
disable-model-invocation: true
argument-hint: <topic words, or a ticket key like MDP-1234>
---

# `/research` — Durable, Reusable Codebase Research

Points at a subject — a topic, or a Jira ticket — and builds an index of
where the relevant docs/code/YARD live, verifies that index against current
code, then answers follow-up questions in the same session by consulting the
index and re-verifying against actual files before answering. Never assumes
an "end of session" — see
[`./rules/research/session_continuity.md`](../../rules/research/session_continuity.md).

When pointed at a ticket, reuses `/develop`'s ticket-scoped `research.md` and
`/planning`'s Feature-scoped `feature_context.md` rather than duplicating
them, so `/research MDP-1234` and `/develop MDP-1234` share artifacts
regardless of order.

The conventions this skill must honor live in
[./rules/meta/instruction_authoring.md](../../rules/meta/instruction_authoring.md).

---

## Invocation

| Command | What it does |
|---|---|
| `/research <topic words>` | Topic-mode — local-only workspace, no Jira ticket. |
| `/research <TICKET-KEY>` | Ticket-mode — reuses/extends the ticket's shared workspace. |
| Plain chat, mid-session, after either of the above | A follow-up question — no need to retype `/research`. |

---

## Dispatch

1. **Parse `$ARGUMENTS`.** If it contains a token matching `[A-Z]+-[0-9]+`,
   that's `ticket_key` (ticket-mode); any remaining text is an optional
   initial question. Otherwise, the entire argument text is the topic
   (topic-mode): `ticket_key` = `RESEARCH-{slug}`, where `slug` is the topic
   normalized to snake_case. Topic-mode's first invocation carries no
   separate question — the topic itself is the scope, not something to
   answer yet.
2. **Detect mode** (`interactive` default, `headless` if
   `_CODE_ENTRYPOINT=sdk-cli`) per
   `./rules/develop/pipeline_modes.md` — needed only for whether
   `AskUserQuestion` is available during topic-mode finding-triage (see
   `./rules/research/findings.md`). Persist to `STATE_research.md`.
3. **Workspace** = `.workspace/{ticket_key}/`.
4. Check `[workspace]/STATE_research.md`:
   - **Absent** → read [pipelines/bootstrap.md](pipelines/bootstrap.md) and
     follow it.
   - **Present** → this is a resume. Per
     `./rules/planning/run_state.md`'s "Trusting completed steps,"
     launch `resume_verify.md` on the bootstrap step (output:
     `topic_index.md`, purpose: "verified index of the topic's docs/code/YARD")
     before continuing.
     - `trusted` or `flagged` → read
       [pipelines/answer.md](pipelines/answer.md) and hand it the (possibly
       empty) question text.
     - `reset` → treat as absent; re-run
       [pipelines/bootstrap.md](pipelines/bootstrap.md).

Either way, this ends by handing the current question (if any) to
`pipelines/answer.md`, whose closing instruction — sourced from
`session_continuity.md`, not restated here — keeps every later plain-chat
turn flowing through the same procedure.

---

## Universal expectations

Before any dispatch:

- **Ensure `/setup verify` has succeeded for this session.** If `/setup`
  hasn't run, run it.
- Read `./rules/planning/run_state.md` and
  `./rules/planning/workspace_sync.md` — every workspace read/write and
  sync call follows those conventions.
- **Ticket-mode**: sync per `workspace_sync.md` before touching local disk.
  **Topic-mode** (`RESEARCH-` prefix): skip sync entirely, same treatment as
  the existing `LOCAL-` convention — the workspace stays purely local.

Do NOT read `pipelines/bootstrap.md` on a resume, or `pipelines/answer.md`
before bootstrap has produced a `topic_index.md` to consult.

---

## Reference reads

- `./rules/research/README.md` — folder index for all research rules.
- `./rules/research/topic_index_schema.md` — `topic_index.md`'s schema
  and the current-state-only principle bootstrap and answer both apply.
- `./rules/research/findings.md` — how doc-defect/bug flags from
  `research_answer.md` get triaged into `doc_review.md`/`findings.md`.
- `./agents/jira_context_fetch.md`, `./agents/research.md` —
  ticket-mode sources bootstrap reuses rather than duplicates.
- `./agents/spike_plan.md`, `./agents/spike.md` — launched
  unmodified by `pipelines/answer.md`'s spike-depth escalation.

---

## Failure modes to watch for

- Ticket-mode: `jira_context_fetch.md` returns a video attachment it
  couldn't process — note it and continue; research doesn't block on it.
- Any mode: `research_index.md` or `research_answer.md` returns
  `NEEDS_DECISION` — resolve it (ask the user in interactive/guided, apply
  the documented default in auto/headless) and re-launch with the answer.
- Topic-mode: a finding-triage ticket offer has no natural parent Feature —
  ask the user which Feature to parent it under; don't guess.
