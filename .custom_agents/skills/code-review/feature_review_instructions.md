# Feature Review — Orchestrator Instructions

You are the orchestrator for a Feature-level review. You coordinate
subagents across every child ticket — you do NOT fetch Jira data, review
code, or judge coverage yourself. Read this whole file once; do not wrap
it in another Agent (subagents here cannot spawn the subagents this file
launches — same constraint as `orchestrator_instructions.md`).

There is no completion gate: a Feature can be reviewed in any state.
Ticket status is context for framing a gap, never a reason to skip it.

## Step 0: Workspace + resumability

**Sync first.** Per the "At orchestrator startup" step in
`./rules/planning/run_state.md`, pull `.workspace/[FEATURE_KEY]/`
from the shared workspace repo
(`./rules/planning/workspace_sync.md`) *before* checking anything on
local disk — the pull can be what brings `STATE_code_review.md` down for
the first time on this machine (e.g. a `/planning` session for this
Feature ran elsewhere). Skipped when sync access is unavailable, per that
rule's degradation table.

Then check whether `.workspace/[FEATURE_KEY]/STATE_code_review.md` exists
(now that the pull has run):

- **Exists, has `pending_steps`** — read it (and `CONTEXT.md`, if
  present), apply the trust/verify check (`resume_verify.md`) to
  `completed_steps`, and resume from the first surviving pending step per
  `./rules/planning/run_state.md`.
- **Doesn't exist, but `.workspace/[FEATURE_KEY]/` holds other skills'
  files** (e.g. a `/planning` session's `STATE_planning.md` or research
  artifacts) — this is a fresh run for code-review regardless. Don't touch
  those other files; `feature_review_fetch` reads the useful ones itself.
  Create `STATE_code_review.md` once the first step succeeds, per
  `run_state.md`'s cross-skill rule — each skill owns only its own file.
- **Nothing exists** — create `STATE_code_review.md` once the first step
  succeeds.

`STATE_code_review.md` means a compaction at *any* point, including the
top level, costs nothing — the next turn re-reads it and resumes.

## Step 1: Fetch

Run `git fetch origin develop` yourself (small, safe). Then launch a
general-purpose Agent: "Read `./agents/feature_review_fetch.md` for
your instructions. Feature: [FEATURE_KEY]. Workspace:
.workspace/[FEATURE_KEY]. Mode: [MODE]."

If it returns `NOT_A_FEATURE: [issuetype]`, stop and tell the user —
suggest `/develop` or standalone `/code-review` instead.

## Step 2: Check out `develop` safely

1. `git status --short`, regardless of mode. If dirty — **including
   untracked files** (a different branch's history can track a path
   that's untracked here) — `git stash push -u -m
   "feature-review-[FEATURE_KEY]-temp"` once, and remember that you
   stashed. One stash, one pop at Step 8, never partial.
2. Remember the current branch: `git branch --show-current`.
3. `git checkout develop && git merge --ff-only origin/develop`. If the
   fast-forward fails:
   - **interactive/guided/auto:** stop and report in chat — a user is
     present to decide.
   - **headless:** not a decision to run through
     `./rules/develop/headless_escalation.md`'s Tiers 1-2 — it's a
     technical failure needing hands-on repo access, not a question a
     reply can resolve. Go straight to its Tier 3: blocker.md, force-commit
     the workspace, push, update the ticket, exit.

These are your own state-changing git ops, not a subagent's, per
`AGENTS.md` "Git ownership."

## Step 3: Coverage batches

Batch `story_bug_children` from Step 1's return into groups of ~3 —
however many batches that takes; there's no cap (Features with 20+
Stories are normal). Launch every batch **in parallel** (one message,
multiple `Agent` calls) — thoroughness matters here, not speed, but
there's no reason to serialize independent batches.

Per batch, launch a general-purpose Agent: "Read
`./agents/feature_review_coverage.md` for your instructions. Ticket
keys: [BATCH KEYS]. review_requirements_file:
.workspace/[FEATURE_KEY]/review_requirements.md. review_changes_file:
.workspace/[FEATURE_KEY]/review_changes.md. base_commit:
[EARLIEST_COMMIT from Step 1]. Workspace: .workspace/[FEATURE_KEY]. Batch
index: [N]."

**Model assessment** (interactive/guided only, skip in auto/headless): if
child-ticket count exceeds ~8 or `candidate_file_count` is large, apply
`./rules/develop/model_assessment.md`'s prompt to recommend Opus
before launching batches.

Wait for all batches to return before continuing.

## Step 4: Synthesis (draft)

Launch a general-purpose Agent: "Read
`./agents/feature_review_synthesis.md` for your instructions.
Phase: draft. Feature: [FEATURE_KEY] — [FEATURE_SUMMARY].
review_requirements_file: .workspace/[FEATURE_KEY]/review_requirements.md.
review_changes_file: .workspace/[FEATURE_KEY]/review_changes.md.
coverage_batch_files: [ALL BATCH FILE PATHS]. prior_review_comment_id:
[from Step 1]. Workspace: .workspace/[FEATURE_KEY]. Mode: [MODE]."

## Step 5: Interactive gate

**auto / headless:** skip entirely — go to Step 6.

**interactive / guided:** follow
`./rules/code_review/feature_review_interactive_ux.md` in full.
This gate can edit `feature_review_report.md` directly (reclassifying
items between Known Issues and Advisory Findings per user feedback).
Don't proceed to Step 6 without the explicit go-ahead that file's closing
message asks for.

## Step 6: Post to Jira

This comment is **documentation** per
`./rules/develop/pipeline_modes.md` (a permanent record, not a
status update) — it posts in every mode. Relaunch the synthesis agent:
"Read `./agents/feature_review_synthesis.md` for your instructions.
Phase: post_confirmed. Feature: [FEATURE_KEY]. prior_review_comment_id:
[from Step 1]. Workspace: .workspace/[FEATURE_KEY]."

## Step 7: Ticket actions for Known Issues

**interactive / guided:** for each Known Issue (never Advisory Findings),
present its title and `Tracked by:` line, then ask what to do:
`Create a new ticket` (default type Story, offer Bug) / `Update the open
ticket` (only offered when `Tracked by:` names an open ticket) / `Skip`.
Accept a free-text batch answer too ("only item 1", "update the open one,
skip the rest") rather than forcing one `AskUserQuestion` per item.

**auto / headless:** skip entirely unless `create_tickets` was passed in
(from `SKILL.md`'s dispatch) — never touch tickets by default. When it
was passed, apply the same two actions to *every* Known Issue with no
per-item selection, since no one is present to ask: `Tracked by:` names
an open ticket → update it; otherwise → create new, always type Story
(no severity heuristic — a wrong guess is worse than the one safe
default).

Either path, per action:

- **Create new** → launch `./agents/planning_jira_create.md` (reused
  as-is) with a brief built from the finding's Detail entry, the chosen
  type, and `parent_key: [FEATURE_KEY]`.
- **Update existing** → launch
  `./agents/feature_review_ticket_update.md` with the ticket key,
  the feature key, the feature summary, and the finding.

Track every Known Issue that got a new or newly-referenced ticket — Step
7.5 needs each one's `local_id` and the resulting ticket key.

## Step 7.5: Patch the comment's ticket references

Only runs if Step 7 acted on at least one Known Issue. The comment Step 6
posted still shows `Tracked by: none` (or the old ticket) for anything
Step 7 just touched — read `[workspace]/review_history.md` for those
items' `local_id`s, then one batched call:

```
mcp__jira__post_feature_review_checklist(
  issue_key: "[FEATURE_KEY]", comment_id: "[the comment posted in Step 6]",
  checklist_items: [{local_id: "[...]", text: "[original line, Tracked by updated]", state: "todo"}, ...]
)
```

One call covering everything Step 7 touched, not one per item. A partial
update only changes the items you name and leaves everything else —
including their position — untouched, per the tool's own guarantee.

## Step 8: Restore the working tree

Always run this, even if an earlier step stopped early:

1. `git checkout [ORIGINAL BRANCH from Step 2]`.
2. If Step 2 stashed, `git stash pop`. If it conflicts, the stash is not
   dropped (`git stash list` still shows it) — nothing is lost, but it
   needs manual resolution:
   - **interactive/guided/auto:** stop and say so explicitly in chat.
   - **headless:** same reasoning as Step 2 — straight to
     `headless_escalation.md` Tier 3, no Tiers 1-2. State the caveat
     plainly in `blocker.md`: the stash lives in local git refs, not
     anything pushed, so resolving it needs this same machine — a
     resumed session elsewhere recovers everything else from
     `STATE_code_review.md`, but not the stash itself.

Never leave the user on `develop`, or silently sitting on an unresolved
stash conflict.

## Step 9: Report

Tell the user: completeness verdict, Known Issue / Advisory counts, the
Jira comment link(s) (more than one if `feature_review_synthesis` split
the report across follow-up comments), any tickets created or updated in
Step 7 (noting the comment was patched to reference them, if Step 7.5
ran), and confirmation the original branch was restored.

## Critical rules

- Fetch, coverage, and synthesis **must** be subagents, launched directly
  from your top-level context — same constraint as
  `orchestrator_instructions.md`.
- `git fetch` / `checkout` / `stash` / `stash pop` are yours to run, never
  a subagent's.
- Compaction safety: `./rules/agent_authoring/compaction_recovery.md`
  applies to every subagent launch here.
- If anything fails irrecoverably, run Step 8 before stopping.
