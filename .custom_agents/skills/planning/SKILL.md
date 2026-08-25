---
name: planning
description: Break a Jira Feature into fully-specced User Stories ready for autonomous development.
disable-model-invocation: true
argument-hint: <feature-key> [auto|guided|interactive|headless]
---

# Feature Planning — Launcher

Parse arguments from: `$ARGUMENTS`

- `$0` — Jira Feature ticket key (e.g., `MDP-230608`). Required.
- `$1` — Mode: `interactive` (default), `guided`, `auto`, or `headless`. Per `../../rules/develop/pipeline_modes.md`, `_CODE_ENTRYPOINT=sdk-cli` auto-elevates to `headless`. Persist mode to `STATE_planning.md`. Note: `/planning` skips force-commit on blocker (no branch context — see `../../rules/develop/headless_escalation.md`).

**Ticket key normalization:**
- Bare number (e.g., `230608`) → add prefix: `MDP-230608`
- Already prefixed (`MDP-230608`) → use as-is
- Empty → ask the user for one

**This skill requires a Jira ticket (MDP- prefix).** Planning creates Stories in Jira.
If the user provides a `LOCAL-` key or says there is no ticket, stop:
"Planning requires a Jira Feature ticket to create Stories under."

## What To Do

**Step 1:** Create a TodoWrite checklist so the user can track progress.

```
1. Fetch Feature (pending)
2. Research Codebase (pending)
3. External Research (pending)
4. Safe Update Strategy (pending)
5. Story Breakdown (pending)
6. Architecture Overview (pending)
7. Detailed Briefs (pending)
8. Create in Jira (pending)
```

**Step 2:** You are the orchestrator. Follow the instructions below directly —
do NOT wrap them in another Agent. (Subagents in this environment cannot spawn
further subagents, so the wrapping pattern silently halts the pipeline.) You
coordinate subagents (research, breakdown, briefs, ticket creation) but
operational work (Jira API calls for fetching, commenting, and ticket creation;
TodoWrite updates; AskUserQuestion prompts) runs in your context. Replace
`[FEATURE_KEY]` and `[MODE]` with the parsed values as you read the instructions.

**Step 3:** As each pipeline step completes, mark the corresponding TodoWrite
item `completed`. When the full pipeline finishes, report the summary.

**Do NOT do the planning work yourself** (research, breakdown, briefs, ticket
construction) — those each go to subagents. **Do** read the planning
instruction files yourself since you are the orchestrator.

You are the orchestrator for a Feature planning pipeline. You coordinate
subagents — you do NOT write code or call APIs yourself (except Jira API
calls for fetching, commenting, and ticket creation).

Feature: [FEATURE_KEY]
Mode: [MODE]

Read `./skills/planning/planning_instructions.md` for your full
instructions. Follow all steps in order.

## Setup Check

Before doing real work, ensure `/setup verify` has succeeded for this session.
If it hasn't, run `/setup` first.

## Setup

1. Read `./rules/LOCAL.md` if it exists for developer-specific overrides. If the file
   doesn't exist, skip this step. If it exists, pass relevant overrides to subagents.
2. Create `.workspace/[FEATURE_KEY]/` if it doesn't exist. Pass this
   path as `workspace:` to all subagents that write output files.
3. **Sync, then check for prior progress.** Per the "At orchestrator
   startup" step in `./rules/planning/run_state.md`, pull
   `.workspace/[FEATURE_KEY]/` from the shared workspace repo
   (`./rules/planning/workspace_sync.md`) *before* checking anything
   on local disk — the pull can be what brings `STATE_planning.md` down for
   the first time on this machine (e.g. a colleague started this Feature's
   planning elsewhere). Then: if `.workspace/[FEATURE_KEY]/STATE_planning.md`
   exists (now that the pull has run), this is a resume. Read it (and
   `CONTEXT.md`, if present) and follow the startup-resume procedure in
   `./rules/planning/run_state.md`: apply the trust/verify check
   (`resume_verify.md`) to `completed_steps`, mark surviving completed and
   skipped steps `completed` in the TodoWrite checklist, honor prior
   `recent_decisions:` and `notes:` from `CONTEXT.md`, and pick up at the
   first surviving `pending_steps` entry. See
   `./rules/planning/run_state.md` for the file format.

## Critical rules

- **Subagents read their own instruction files.** Don't duplicate instructions.
- **Pass structured context** (key: value), not accumulated prose.
- If a step returns SKIP, report briefly and move on.
- If a step returns NEEDS_DECISION, ask the user, then re-launch with the answer.
- In auto mode, only stop for errors. In interactive mode, ask before each step.
- **Use AskUserQuestion** for finite choices (Proceed/Skip/Handle, Yes/No, Option A/B).
- Even in auto mode, **always confirm before creating Jira tickets**.
- **Compaction safety:** see `./rules/agent_authoring/compaction_recovery.md`
  for the full protocol — progress check, model escalation on no-progress
  compaction, and reporting any escalations in the pipeline-end summary.
- **Never accumulate large results in this context.** Subagents write output to
  workspace files and return only brief summaries.
- **Update TodoWrite progress** after each numbered step completes. Mark the
  corresponding checklist item as `completed`.
- **The orchestrator IS the top-level conversation.** There is no separate
  orchestrator subagent in this environment — subagents cannot spawn further
  subagents. Every "Launch general-purpose Agent" call below originates from
  your top-level context.
