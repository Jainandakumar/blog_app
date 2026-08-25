---
name: develop
description: Full development pipeline from Jira ticket to committed code using coordinated subagents.
disable-model-invocation: true
argument-hint: <ticket-key> [auto|guided|interactive|headless|fix]
---

# Development Pipeline — Launcher

Parse arguments from: `$ARGUMENTS`

- `$0` — Jira ticket key (e.g., `MDP-12345`) or mode. Optional.
- `$1` — Mode or ticket key (order is flexible).

**Argument parsing:**
- If `$1` is `fix` — mode is `fix`, ticket key is `$0`.
- If `$0` is `fix` — mode is `fix`, ticket key is `$1` (if present).
- Otherwise — ticket key is `$0`, mode is `$1`. Default mode per `pipeline_modes.md` (interactive, unless `_CODE_ENTRYPOINT=sdk-cli` elevates to `headless`). Keywords `unattended`/`non-interactive` map to `headless`. Persist mode to `STATE_develop.md`.

**Ticket key normalization** (apply before launching the pipeline):
- Bare number (`12345`) → add prefix: `MDP-12345`.
- Already prefixed (`MDP-12345`, `LOCAL-000001`) → use as-is.
- Empty → pass empty (Setup step asks the user).

## Setup Check

Before doing real work, ensure `/setup verify` has succeeded for this
session. If it hasn't, run `/setup` first.

## What To Do

**Step 1: TodoWrite checklist.**

Standard / spike pipelines:

```
1. Jira (pending)
2. Validate (pending)
3. Model Assessment (pending)
4. Plan (pending)
5. Research (pending)
6. Architecture (pending)
7. Design (pending)
8. Code (pending)
9. Test (pending)
10. Review (pending)
11. Commit (pending)
12. Monitor Pipeline (pending)
13. Merge (pending)
```

Fix pipeline:

```
1. Read Feedback (pending)
2. Evaluate & Plan (pending)
3. Fix (pending)
4. Test Locally (pending)
5. Review & Push (pending)
6. Wait & Re-check (pending)
7. Resolve Discussions (pending)
8. Merge (pending)
```

**Step 2: Run the orchestration directly.** You are the orchestrator —
do NOT wrap the pipeline in another Agent. Subagents in this environment
cannot spawn further subagents, so the wrapping pattern silently halts the
pipeline. You delegate the per-step development work (plan, research,
architecture, design, code, test, review) to subagents via the Agent
tool. Operational work (git, Jira/GitHub API calls, pipeline monitoring,
TodoWrite updates, `AskUserQuestion` prompts) runs in your context.

Mode semantics live in `./rules/develop/pipeline_modes.md`.

**Step 3: Track progress.** Mark each TodoWrite item `completed` as the
corresponding step finishes. Report the final summary at the end.

## Setup (run before pipeline steps)

1. **Resolve ticket key.** If a key was provided, use it (add `MDP-` prefix if
   it's a bare number). If none was provided:
   - If the current branch matches `MDP-NNNNNN_*` or `LOCAL-NNNNNN_*`, **suggest**
     that ticket ("You're on branch `[branch]` — work on `[TICKET_KEY]`? Or give
     me a different ticket."). Confirm before using it — don't presume.
   - Otherwise ask: "What ticket are you working on?"
   - If the user says there is no ticket: generate a `LOCAL-` key. Check
     existing `.workspace/LOCAL-*/` directories, take the highest number, add 1
     (or `LOCAL-000001` if none).

2. **Set `ticket_type`** based on the resolved ticket key prefix:
   - `MDP-*` → `ticket_type: jira` (full pipeline: Jira + GitHub + push + merge).
   - `LOCAL-*` → `ticket_type: local` (skip all Jira/GitHub operations,
     branch + commit only, interactive mode only). Changes not tied to a
     Jira ticket cannot be merged into protected branches.
   - If mode is `auto` or `guided` and `ticket_type` is `local`: downgrade
     to `interactive` silently.

3. **Resume / prior-artifact check.** Before starting fresh, look for prior
   work on this ticket:
   - **Sync first.** Per the "At orchestrator startup" step in
     `./rules/planning/run_state.md`, pull `.workspace/[TICKET_KEY]/`
     from the shared workspace repo
     (`./rules/planning/workspace_sync.md`) *before* checking anything
     on local disk — the pull itself can be what brings `STATE_develop.md`
     down for the first time on this machine (a colleague's `/planning`
     session, or a `/develop` run resumed on different hardware). Skipped
     for `LOCAL-` tickets or when sync access is unavailable, per that
     rule's ticket-validity gate and degradation table.
   - **`.workspace/[TICKET_KEY]/STATE_develop.md` exists** (now that the
     pull has run) → this run is a **resume**.
     Read it (and `CONTEXT.md`, if present) and follow the startup-resume
     procedure in `./rules/planning/run_state.md`: apply the
     trust/verify check (`resume_verify.md`) to `completed_steps`, begin at
     the first surviving `pending_steps` entry, honor prior
     `recent_decisions` from `CONTEXT.md`, and rebuild structured context
     from `STATE_develop.md` and the workspace files. For a `jira` ticket
     with an open MR, also run the ticket-comment / MR-discussion delta
     check in `./rules/develop/pipeline_modes.md`.
     - **Interactive / guided:** report where it left off (last completed step,
       next step) and confirm via `AskUserQuestion`: `Resume` / `Start over`.
       On `Start over`, clear `STATE_develop.md` and run fresh.
     - **Auto / headless:** resume silently.
   - **No `STATE_develop.md`, but `.workspace/[TICKET_KEY]/` holds other
     files (e.g. a `/research` run's `topic_index.md`/`research.md`, or a
     `/planning` session's artifacts), or a `[TICKET_KEY]_*` branch exists**
     → run a **normal cycle**, treating the prior artifacts as context: have
     Validate and Plan read the existing workspace notes and the local
     branch diff (`git diff`, staged, and committed vs `develop`) so the
     pipeline doesn't redo or clobber work already in progress.
   - **Nothing exists** → normal fresh cycle.

   ` -p` continues to pass `--resume`, which routes into the same
   startup-resume procedure; this step lets a re-invoked `/develop [TICKET]`
   behave the same way without the flag.

4. **Jira setup check** (`ticket_type: jira` only):
   Launch a general-purpose Agent:
   > "Read `./agents/setup_check.md` for your instructions. Component: jira"
   - Returns `OK` or `OK (fixed)`: continue.
   - Returns `SKIPPED`: continue without Jira (`ticket_type` becomes `local`).
   - Returns `FAILED`: stop and report the reason.

5. **Read `./rules/LOCAL.md`** if it exists for developer-specific
   overrides. Extract preferences relevant to each step (commit rules, test
   rules, style rules, etc.) and pass them as
   `Local overrides: [relevant items]` in prompts. If the file doesn't
   exist, pass nothing.

6. **Create the workspace** `.workspace/[TICKET_KEY]/` if it doesn't already
   exist — pass this path as `workspace:` to all subagents that write output
   files. On resume it already exists; reuse it.

7. **Clean up `.-touched-files`** per
   `./rules/agent_authoring/touched_files.md` (startup cleanup
   section).

## Pre-check

If mode is `fix` and `ticket_type` is `local`: stop and report:

> "Fix mode requires a Jira ticket with a pushed MR. `LOCAL-` tickets
> don't have MRs. Use `/develop [ticket-key] fix` with a `MDP-` ticket key."

## Dispatch

1. **`fix` mode:** read `./skills/develop/pipelines/fix.md` and
   follow it. Do not read `develop.md` — the fix pipeline is
   self-contained.
2. **Otherwise (`ticket_type: jira`):** read
   `./skills/develop/pipelines/steps/01_jira.md` first to fetch the
   ticket and gate on type. Then continue with
   `./skills/develop/pipelines/develop.md` (or `spike.md` if the
   ticket is a Spike — `01_jira.md` returns the type so you can route).
3. **Otherwise (`ticket_type: local`):** skip the Jira step — ask the
   user for requirements and a branch name (per
   `./rules/git/branch_naming.md`), then read
   `./skills/develop/pipelines/develop.md` and follow it.

## Critical rules

- **`ticket_type` governs Jira/GitHub operations.** Include
  `ticket_type: jira | local` in structured context for all subagents.
  If `local`: skip all Jira/GitHub steps, do not push or create MRs,
  commit locally only.
- **Development steps MUST launch a subagent** via the Agent tool (plan,
  research, architecture, design, code, test, review). Operational steps
  (git, Jira/GitHub API calls, pipeline monitoring) run in orchestrator
  context.
- **Subagents read their own instruction files.** Don't duplicate
  instructions in prompts.
- **Pass structured context** (key: value), not accumulated prose.
- **Pass LOCAL.md overrides** relevant to each subagent's task.
- If a step returns SKIP, report briefly and move on.
- If a step returns NEEDS_DECISION, route per the pipeline file's rules.
- **Use `AskUserQuestion`** for finite choices (Proceed/Skip/Handle,
  Yes/No, Option A/B). Free-text prompts only for open-ended questions.
- **Compaction safety:** see
  `./rules/agent_authoring/compaction_recovery.md`.
- **Never accumulate large results in this context.** Subagents write
  output to workspace files and return brief summaries per
  `./rules/agent_authoring/workspace_output.md`.
- **Update TodoWrite progress** after each numbered step completes.
- **The orchestrator IS the top-level conversation.** Every "Launch
  general-purpose Agent" call originates from your top-level context.

## Issue reporting

See [`issue_reporting.md`](issue_reporting.md) for when to launch
`report_issue` and how.
