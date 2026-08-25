# Fix Pipeline (MR Feedback Loop)

Loop: Read Feedback → Evaluate & Plan → Fix → Test → Review & Push → Wait
Exit: All green → Resolve Discussions → Merge

**Usage:** `/develop fix` or `/develop MDP-12345 fix`.

**Orchestrator rule:** You do NOT write code or fix issues yourself.
All code changes (including Pronto/lint fixes) go through subagents.
Git operations, Jira/GitHub API calls, and pipeline monitoring run
directly in your context.

**Shell state rule:** Shell variables do NOT persist between Bash tool
calls. When a command produces a value needed later (like MR IID or
pipeline ID), capture it from the output and inline the literal value
into all subsequent Bash commands.

## Pre-check

Create `.workspace/[TICKET_KEY]/` if it doesn't exist.

## Context passing

Maintain a structured summary across steps. Update after Steps 1 and 2:

```
ticket: [TICKET_KEY]
ticket_type: jira (fix pipeline requires a Jira ticket with an MR)
issue_type: [Story | Bug | Task | Spike — from caller or fetched in Step 8]
branch: [BRANCH]
mr_iid: [MR_IID]
workspace: [workspace path]
feedback_summary: [categorized from Step 1]
fix_plan: [ordered fix list from Step 2]
```

Pass the current version to each subagent.

---

## STATE_develop.md update protocol

After every step, follow the full "After every step completes" protocol
in `./rules/planning/run_state.md` — update
`[workspace]/STATE_develop.md` **and push it** to the shared workspace
repo (`./rules/planning/workspace_sync.md`); the push is part of
that protocol, not a separate step. Inline orchestrator work — not in
TodoWrite.

---

## Step 1: Read Feedback

See [`steps/fix_01_read_feedback.md`](steps/fix_01_read_feedback.md).

---

## Step 1.5: Model assessment

After Step 1 (feedback in hand): apply
[`../../../rules/develop/model_assessment.md`](../../../rules/develop/model_assessment.md)
against the feedback content (files touched, presence of
architectural critique). Skip in `auto` / `headless`. Not in
TodoWrite.

---

## Step 2: Evaluate & Plan

```
"Read `./agents/evaluate.md` for your instructions.

Workspace: [workspace path]

MR feedback to evaluate:
- Code review comments: [COMMENTS]
- Test failures: [FAILURES — full logs in [workspace]/job_*_log.txt]
- Warnings: [WARNINGS]
- Build errors: [ERRORS]

Write full evaluation to [workspace]/evaluation.md.
Return: summary counts only (RED, YELLOW, flaky)."
```

**Interactive/guided:** present the fix plan and confirm before
proceeding.
**Auto:** proceed unless there are YELLOW items that need a judgment
call — present those and ask, then continue with RED fixes
autonomously.

---

## Step 3: Fix

See [`steps/fix_03_fix.md`](steps/fix_03_fix.md).

---

## Step 4: Test Locally

```
"Read `./agents/test.md` for your instructions.

Files modified: [FILES from Step 3]
Workspace: [workspace path]
Local overrides: [relevant items from LOCAL.md]

Run affected tests: `bundle exec rspec [file]`
Write results to [workspace]/test_results.md.
Report pass/fail for each."
```

If tests fail: report to user. Don't loop internally.

---

## Step 5: Review & Push

See [`steps/fix_05_review_push.md`](steps/fix_05_review_push.md).

---

## Step 6: Wait & Re-check

6.1. Report: "Changes pushed. Pipeline runs ~15-45 min."

Polling follows `./rules/integrations/github_pipeline_polling.md`,
including the Monitor cap (default 4 iterations; reset on entry to
this step). If the cap is reached with the pipeline still running,
write `state/blocker.md`, post a Jira comment, and exit cleanly.

6.2. Green → Step 7. Red → back to Step 1, **max 3 retry cycles**.
After 3 cycles still red: write `state/blocker.md` with accumulated
failures, post a Jira comment, exit cleanly. User can re-launch fix
after manual investigation.

**Flaky special case:** if only failure is a locally-passing test,
ask user to retry the job manually. Don't push empty commits or
count this against the retry cap.

---

## Step 7: Resolve Discussions

7.1. Fetch unresolved discussions:

```
mcp__github__get_discussions(mr_iid: N)
```

7.2. For each unresolved discussion, reply then resolve:

```
mcp__github__reply_to_discussion(mr_iid: N, discussion_id: "...", body: "Reply text")
mcp__github__resolve_discussion(mr_iid: N, discussion_id: "...")
```

- **Fixed this session:** reply with fix description, resolve.
- **Acknowledged warning:** reply with reasoning, resolve.
- **Human comment addressed:** reply referencing commit, resolve.
- **Not addressed:** leave unresolved, report to user.

7.3. Report summary.

---

## Step 8: Merge

**Auto mode:** merge automatically. **Interactive/guided:** ask first.

```
mcp__github__merge_mr(mr_iid: N)
```

Pre-merge: verify pipeline success, no unresolved discussions. Never
force-merge.

After merge, advance the Jira ticket status per
`./rules/jira/status_rules.md` (end-of-work transitions). If
`issue_type` is not in your context, fetch it:
`mcp__jira__get_issue(issue_key: "[TICKET_KEY]")` and read
`issuetype`. Use `mcp__jira__transition_issue` to advance.

---

## Progress

```
Fix Pipeline Complete: MDP-12345
  1. Read Feedback:   Done — ...
  2. Evaluate & Plan: Done — ...
  3. Fix:             Done — ...
  4. Test Locally:    Done — ...
  5. Review & Push:   Done — ...
  6. Wait & Re-check: Done — ...
  7. Resolve:         Done — ...
  8. Merge:           Done — ...
```
