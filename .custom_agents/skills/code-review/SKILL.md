---
name: code-review
description: Run a local code review matching CI pipeline standards. Pass a Story/Bug/Task ticket key to also verify the branch against that ticket's requirements/AC, or a Feature ticket key for a Feature-level review across all its child tickets (no completion gate). Scans for issues, reports them, then fixes them (or posts a report to Jira for a Feature).
disable-model-invocation: true
argument-hint: "[ticket-key] [auto|guided|interactive|headless] [create-tickets]"
---

# Local Code Review — Launcher

**Mode.** Detect per `../../rules/develop/pipeline_modes.md`
(`_CODE_ENTRYPOINT=sdk-cli` → `headless`; otherwise `interactive`).
In `headless`/`auto`, skip the fix-confirmation `AskUserQuestion` and
apply all suggested fixes automatically.

## Step 0: Dispatch

If `$ARGUMENTS` starts with a ticket-key-shaped token (`[A-Z]+-[0-9]+`),
fetch it directly — `mcp__jira__get_issue(issue_key: "[KEY]")` — to read
`issuetype` before deciding where this goes. One lookup, no subagent
needed for it (same pattern `./skills/jira/SKILL.md` uses).

- **`issuetype` is `Feature`** — this is a **Feature-level review**. Also
  check for a `create-tickets` token anywhere in `$ARGUMENTS` — it only
  matters in auto/headless (where no one is present to ask per-item);
  interactive/guided always ask regardless of this flag. Create a
  TodoWrite checklist —

  ```
  1. Fetch Feature + children (pending)
  2. Check out develop (pending)
  3. Coverage review (pending)
  4. Synthesize draft (pending)
  5. Interactive review (pending — skipped in auto/headless)
  6. Post to Jira (pending)
  7. Ticket actions (pending — skipped in auto/headless unless create-tickets)
  7.5. Patch comment references (pending — only if Step 7 ran)
  8. Restore working tree (pending)
  ```

  — then read
  [`feature_review_instructions.md`](feature_review_instructions.md) and
  follow it as the orchestrator (same "do NOT wrap in another Agent" rule
  as Step 2 below), passing through the `create_tickets` flag. There is
  no completion gate — a Feature can be reviewed in any state.

- **`issuetype` is `Story`, `Bug`, or `Task`** — this is a **single-ticket
  review**. Pull both `description_text` and `acceptance_criteria` from
  this same fetch — some tickets keep AC as a numbered section inside the
  description body instead of the structured field, so capture both
  rather than assuming one location — then continue with the
  branch-review pipeline below (Steps 1-3), passing this ticket's key,
  requirements, and criteria into Step 2 as ticket context — the same
  shape `/develop` Step 10 passes inline.

- **Any other `issuetype`** (Spike, DevOps Request, etc.) — report and
  stop: "`[KEY]` is a `[issuetype]` — no review pipeline covers that
  type. Use standalone `/code-review` (no ticket key) to review the
  branch on its own, or `/develop [KEY] fix` if you're implementing or
  fixing it."

If `$ARGUMENTS` has no ticket-key-shaped token, continue with the
branch-review pipeline below (Steps 1-3), with no ticket context.

## Branch-review pipeline

**Step 1:** Create a TodoWrite checklist. If Step 0 fetched ticket
context, prepend `0. Fetch ticket (completed)`:
```
1. Scan changes & run Pronto (pending)
2. Review code (pending)
3. Report findings (pending)
4. Fix issues (pending)
```

**Step 1.5: Model assessment.** After the scan in Step 1 produces a diff
summary, apply [`../../rules/develop/model_assessment.md`](../../rules/develop/model_assessment.md).
The relevant heuristic for code-review is the diff-size signal:
recommend Opus when the diff exceeds **200 changed lines OR 5 files**.
Skip in `auto` / `headless`. Not tracked in TodoWrite.

**Step 2:** You are the orchestrator. Read
`./skills/code-review/orchestrator_instructions.md` and follow all steps
in order — do NOT wrap that in another Agent. (Subagents in this environment
cannot spawn further subagents, so the wrapping pattern silently halts the
review.) The review and fix steps in orchestrator_instructions.md DO use
subagents, which works because they're launched from your top-level context.
If Step 0 fetched ticket context (Story/Bug/Task path), pass the ticket
key, requirements, and criteria through per its own Step 2 "ticket
context was provided" handling.

**Step 3:** As each pipeline step completes, mark the corresponding TodoWrite
item `completed`. When the full pipeline finishes, report the summary.

**Do the operational work yourself** (scan, classify, report). **Do NOT do the
review or fix work yourself** — those go to subagents per orchestrator_instructions.md.

---

## Setup Check

Before doing real work, ensure `/setup verify` has succeeded for this session.
If it hasn't, run `/setup` first.
