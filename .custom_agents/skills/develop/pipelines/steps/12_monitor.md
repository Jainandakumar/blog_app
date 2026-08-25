# Step 12: Monitor Pipeline (auto/headless modes, `ticket_type: jira` only)

**Skip if `ticket_type: local`** (no MR to monitor).

**Interactive/guided modes:** do not auto-monitor. Present the pipeline monitoring gate after reporting the MR URL:

> "A new Merge Request has been created: [MR_URL]
> Would you like me to monitor the pipeline for comments and failures?"

Options:
- `Yes — monitor pipelines` → proceed to polling below
- `No — I'll check on it myself` → stop here; the MR URL has been reported

**Auto/headless modes:** proceed directly to polling.

In auto/headless modes, poll GitHub until the pipeline reaches a
terminal status. The polling protocol — find_mr/get_mr cadence, the
foreground `sleep` interval, the Monitor cap, what counts as a
terminal status — lives in
`./rules/integrations/github_pipeline_polling.md`. Follow that
rule.

**Cap source**: read the cap from the natural-language portion of
the original prompt if the user specified one; otherwise use the
default (4 iterations). Reset the cap counter every time control
enters this step (initial entry, or re-entry after a fix cycle).

Outcomes:

12.1. **Status terminates in `success`:** the MR object you already
have carries `merge_status`, `head_pipeline.web_url`, and discussion
state. Proceed to Step 13 (Merge).

12.2. **Cap reached with pipeline still running:** stop polling and
follow the cap-hit behavior in
`./rules/integrations/github_pipeline_polling.md` (write
`state/blocker.md`, post Jira comment, exit cleanly). The user can
re-launch `/develop` to resume monitoring.

12.3. **New discussion arrived mid-pipeline** (any source — CCR,
Pronto bot, or human reviewer): route to the fix pipeline
immediately. The polling rule's "Comment handling" section dictates
this — addressing the comment + pushing cancels the running
pipeline and avoids waiting through redundant CI runtime. Update
`CONTEXT.md`'s `last_known_discussions.latest_note_id` before entering
fix. Use the same fix-pipeline routing as 12.4 below.

12.4. **Status terminates in `failed`, `canceled`, or `skipped`:**
orchestrate the fix pipeline inline by reading
`./skills/develop/pipelines/fix.md` and following its steps
yourself. Do NOT launch a wrapping fix-orchestrator subagent —
subagents cannot spawn further subagents in this environment.

Before entering fix, fetch logs for **all** failing jobs via
`mcp__github__get_pipeline_jobs` + `mcp__github__get_job_log`; pass
the consolidated failure list to the fix pipeline. Avoid the
push-once-per-failure pattern (which restarts RSpec for each fix).

Carry forward the structured context you already have:

```
ticket: [TICKET_KEY]
ticket_type: jira
issue_type: [TYPE from Jira step]
branch: [BRANCH]
mr_iid: [MR_IID]
mode: auto
workspace: [workspace path]
```

Read `./rules/LOCAL.md` if it exists; pass relevant overrides to
subagents you spawn for fix.md's per-step work.

The fix pipeline's own critical rules (subagents read their own files,
structured context, AskUserQuestion for finite choices, NEEDS_DECISION
escalation, compaction safety) apply directly — fix.md owns them.

**After fix.md's pipeline completes:**

- **Merged:** report completion — **skip Step 13** (already done).
  The pipeline is complete.
- **Pushed but not merged:** the new pipeline hasn't completed yet.
  Resume polling per
  `./rules/integrations/github_pipeline_polling.md`.
- **Unresolved:** report what remains to the user and stop.
