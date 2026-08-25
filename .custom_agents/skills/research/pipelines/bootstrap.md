# `/research` — Bootstrap pipeline

Numbered, terminates. Runs once per workspace to build `topic_index.md`;
every later question — including the first one, if `SKILL.md` parsed one —
goes through [`answer.md`](answer.md) instead.

## Step 1: Resolve mode, construct workspace, sync

Already resolved by `SKILL.md`'s dispatch: `ticket_key`, mode, and
`workspace = .workspace/{ticket_key}/`. Ticket-mode syncs per
`./rules/planning/workspace_sync.md` before touching local disk;
topic-mode (`RESEARCH-` prefix) skips sync entirely per that rule's
ticket-validity gate.

## Step 2: Create the workspace

If `[workspace]/` doesn't exist, create it. Write
`[workspace]/CONTEXT.md` and `[workspace]/STATE_research.md` per
`./rules/planning/run_state.md`'s format (`ticket_key`, `mode`,
`started_at`, empty `completed_steps`/`skipped_steps`, `pending_steps: [1]`).

## Step 3: Ticket-mode only — Jira context and reused ticket research

Skip entirely in topic-mode.

1. **Fetch ticket context:**
   ```
   "Read `./agents/jira_context_fetch.md` for your instructions.

   Ticket: [TICKET_KEY]
   Workspace: [workspace path]
   Mode: [MODE]
   Output filename: jira_context.md"
   ```

2. **Reuse or regenerate `research.md`.** If `[workspace]/research.md`
   doesn't exist, launch it fresh (below). If it does exist, don't assume
   it's current — a prior `/develop` run produced it, possibly long ago.
   Launch `resume_verify.md`:
   ```
   skill: develop
   workspace: [workspace path]
   ticket_key: [TICKET_KEY]
   step: 5 (develop's Research step)
   completed_at: unmarked
   output_files: [workspace]/research.md
   output_purpose: Ticket-scoped codebase research (files, patterns, reusable
     code) `/develop` used to plan its implementation — being reused here as
     one source for this topic's index.
   ```
   `trusted` or `flagged` → reuse `research.md` as-is (any flags are already
   annotated in place). `reset` → regenerate it now:
   ```
   "Read `./agents/research.md` for your instructions.

   Context: [ticket summary from jira_context.md]
   Workspace: [workspace path]
   Local overrides: [relevant items from LOCAL.md]

   Find relevant patterns, related files, reusable code, and conventions for
   this ticket. Write findings to [workspace]/research.md."
   ```

## Step 4: Build/verify `topic_index.md`

```
"Read `./agents/research_index.md` for your instructions.

Mode: build
Topic: [topic name + topic_slug]        (or: Ticket: [TICKET_KEY], ticket-mode)
Workspace: [workspace path]
sources_available: [research.md / jira_context.md / feature_context.md paths present, or none]"
```

`research_index.md` folds in whatever ticket-mode sources are available as
one more input, bounded by the current-state-only principle in
`./rules/research/topic_index_schema.md`.

## Step 5: Mark bootstrap complete, hand off

1. Update `[workspace]/STATE_research.md`: move step 1 to `completed_steps`
   with `completed_at`; `pending_steps` becomes empty.
2. Ticket-mode: push per `workspace_sync.md`.
3. Present a short summary of `topic_index.md` (row counts per section, any
   `Open questions / gaps`) to the user.
4. If `SKILL.md` parsed an initial question (ticket-mode only — see
   `SKILL.md`'s Dispatch), hand it to [`answer.md`](answer.md) now.
   Otherwise, stay open for the first question per
   `./rules/research/session_continuity.md` — no further action here.
