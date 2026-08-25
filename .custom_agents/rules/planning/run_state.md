---
last_reviewed: 2026-08-18
---

# Run state and resumability (shared workspace state)

Every orchestrator skill maintains progress files at `[workspace]/` so a
fresh orchestrator — one spawned where `SendMessage` is unavailable, one
resumed via ` -p --resume`, one re-invoked as `/develop [ticket]` on a
ticket that already has state, or one returning to a ticket touched by a
sibling skill earlier — can resume cheaply without redoing completed work.

**Skills interleave on the same ticket in any order, any number of times**
(e.g. `planning → planning → develop → research → develop → code-review →
develop → research → code-review`), possibly by different developers at
different times (the workspace syncs — see `workspace_sync.md`). Two kinds
of file, split by who owns what, are what make this safe:

- **`[workspace]/CONTEXT.md`** — cross-skill shared carry-forward. Any skill
  may read or append to it; no skill's entries are ever overwritten by
  another's.
- **`[workspace]/STATE_<skill>.md`** — one per skill that has ever run on
  this ticket, owned exclusively by that skill. A skill reads and writes
  only its own file, never another skill's. This is what lets each skill
  resume exactly where *it* left off, unaffected by what ran in between.

---

## CONTEXT.md format

YAML-shaped, read and written as plain text — no YAML parser required.

```
ticket_key: MDP-230608
recent_decisions:
  - skill: planning
    step: 4
    question: "Approve safe update strategy?"
    answer: "Approved as drafted"
    timestamp: 2026-05-27T15:30:00Z
last_known_comments:          # for --resume diff (Jira ticket)
  fetched_at: 2026-05-27T15:42:00Z
  latest_comment_id: "10473819"
last_known_discussions:       # for --resume diff (GitHub MR, when applicable)
  fetched_at: 2026-05-27T15:42:00Z
  latest_note_id: 9847263
notes: |
  Pre-resolved scope: <one-line summary of any user-supplied scope decisions
  that should override the default flow>
```

Append-only on every field. Keep `notes:` short (under ~10 lines) — the full
output of each step belongs in its dedicated workspace file (`plan.md`,
`research.md`, `topic_index.md`, etc.), not here.

## STATE_\<skill\>.md format

One file per skill: `STATE_develop.md`, `STATE_planning.md`,
`STATE_research.md`, `STATE_jira.md`, `STATE_github.md`,
`STATE_code_review.md`, `STATE_document.md`, `STATE_author.md` — created
lazily, only for a skill that has actually run on this ticket.

```
ticket_key: MDP-230608
mode: headless                # interactive | guided | auto | headless
started_at: 2026-05-27T15:00:00Z
last_updated_at: 2026-05-27T15:42:00Z
completed_steps:
  - step: 1
    completed_at: 2026-05-27T15:05:00Z
  - step: 2
    completed_at: 2026-05-27T15:20:00Z
skipped_steps: [3]
pending_steps: [4, 5]
```

`mode` is per skill-run, not shared — the same ticket could see `/develop`
run in `auto` while `/research` is invoked `interactive` in a separate
session; each STATE file records its own.

Same ticket, same skill, run by a different developer or resumed months
later — reads and resumes from this same file, because it lives in the
synced workspace, not locally. That's exactly why a completed step isn't
trusted blindly on resume; see "Trusting completed steps" below.

---

## At orchestrator startup

0. **Sync the workspace first**, per [`workspace_sync.md`](workspace_sync.md)
   — pull before doing anything else, including before checking whether any
   state file exists locally. Skipped for `LOCAL-`/`RESEARCH-` keys or when
   sync access is unavailable, per that rule's degradation matrix.
1. Read `[workspace]/CONTEXT.md` if it exists — every skill uses its
   `recent_decisions`/`notes`/comment-tracking, not just whichever skill
   wrote them.
2. Read `[workspace]/STATE_<own-skill>.md` if it exists. Honor
   `skipped_steps`.
3. Apply **"Trusting completed steps"** (below) to every step in
   `completed_steps`, and to any step in `pending_steps` (or absent
   entirely) whose expected output file already exists on disk — before
   deciding what to actually skip.
4. Begin from the first surviving step in `pending_steps`.
5. **If this is a resume** (` -p --resume`, or the skill re-invoked
   when `STATE_<own-skill>.md` already exists): perform the
   ticket-comment-check per
   [`../develop/pipeline_modes.md`](../develop/pipeline_modes.md) — fetch
   ticket comments via `mcp__jira__get_issue` and (when an MR exists)
   `mcp__github__get_discussions`; diff against `CONTEXT.md`'s
   `last_known_comments` / `last_known_discussions`. Surface any deltas
   before resuming step work.
6. If `[workspace]/STATE_<own-skill>.md` does NOT exist, this is a fresh run
   **for this skill** — regardless of what other skills' `STATE_*.md` files
   already exist for this ticket. Create it (and `CONTEXT.md`, if that also
   doesn't exist) once the first step succeeds.

---

## Trusting completed steps — launch `resume_verify.md`

Don't blindly skip everything in `completed_steps`. Launch
[`./agents/resume_verify.md`](../../agents/resume_verify.md) once per
resume, covering every completed step plus any pending/absent step whose
expected output already exists on disk. Pass, per step: the skill name, the
workspace path, the ticket key, `completed_at` (or `unmarked` if the step
isn't recorded complete but its output exists), the step's output file
path(s), and a one-line description of what that output represents.

It returns a verdict per step — `trusted`, `flagged`, or `reset`. Apply any
`reset` verdict to `STATE_<own-skill>.md` (move the step back to
`pending_steps`, drop its `completed_at`) before continuing; `flagged`
verdicts are already annotated in place by the agent and need no further
action here. See `resume_verify.md` for the full decision contract — the
orchestrator's only job is to launch it with the right inputs and apply its
verdicts.

---

## After every step completes

Update `[workspace]/STATE_<own-skill>.md`:

- Move the step from `pending_steps` to `completed_steps` (with
  `completed_at`), or to `skipped_steps` if SKIP was returned.
- Bump `last_updated_at`.

If the step produced a decision, a comment-tracking update, or anything a
later skill on this ticket should see, append it to `[workspace]/CONTEXT.md`
too.

**Push the workspace**, per [`workspace_sync.md`](workspace_sync.md) — after
both updates above, so the pushed state reflects them.

---

## After every user decision (or autonomous decision in headless mode)

Any `AskUserQuestion` answer, any `NEEDS_DECISION` resolution, or any Tier 1
autonomous decision (headless mode) — append to `CONTEXT.md`'s
`recent_decisions:` (tagged with the current `skill:`) so a later
orchestrator, on this skill or any other, has the same context.

---

## Related

- [`workspace_sync.md`](workspace_sync.md) — the pull/push protocol
  referenced by "At orchestrator startup" and "After every step
  completes" above; also covers the ticket-validity gate, the secrets
  convention, and access-failure degradation.
- [`../../agents/resume_verify.md`](../../agents/resume_verify.md) — the
  trust/verify judgment for completed and unmarked-but-present steps.
- [`../develop/pipeline_modes.md`](../develop/pipeline_modes.md) — mode
  taxonomy + resume ticket-comment-check.
- [`../develop/headless_escalation.md`](../develop/headless_escalation.md)
  — three-tier escalation contract that writes to
  `[workspace]/state/escalation.json` and `state/blocker.md` (siblings
  to the state files above).
- [`../../skills/planning/SKILL.md`](../../skills/planning/SKILL.md) — the
  `/planning` orchestrator.
- [`../../skills/develop/SKILL.md`](../../skills/develop/SKILL.md) — the
  `/develop` orchestrator (also reads/writes state on the same ticket).
- [`../../skills/planning/planning_instructions.md`](../../skills/planning/planning_instructions.md)
  — the detailed step-by-step procedure that updates state after each step.
