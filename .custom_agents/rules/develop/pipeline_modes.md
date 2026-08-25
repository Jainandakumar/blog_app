---
last_reviewed: 2026-08-05
---

# Pipeline modes

Orchestrator skills run in one of four modes — `interactive` (default),
`guided`, `auto`, or `headless`. The mode controls **when the pipeline
pauses**, **where status updates go** (chat vs. Jira/GitHub), **how
`NEEDS_DECISION` is escalated**, and **how a shared-workspace-sync access
failure degrades** (see [`../planning/workspace_sync.md`](../planning/workspace_sync.md)).
The mode is detected
once at Phase 0 of each skill and persisted to that skill's own
`STATE_<skill>.md` so every later phase reads it without re-inferring.

Although this rule originated for `/develop`, the modes apply to every
orchestrator skill (`/develop`, `/planning`, `/jira`, `/github`,
`/code-review`, `/document`, `/author`).

## Mode detection

Phase 0 of every orchestrator skill sets the mode in this order of
precedence:

1. **Explicit keyword in `$ARGUMENTS`** — `interactive`, `guided`,
   `auto`, `headless`, `unattended`, or `non-interactive`. The first three
   set the mode directly; the last two map to `headless`.
2. **Environment signal** — if `_CODE_ENTRYPOINT=sdk-cli`
   (set by ` -p`), elevate to `headless` (no keyword needed).
3. **Default** — `interactive`.

The detected mode is recorded in `.workspace/{ticket}/STATE_<skill>.md`:

```
mode: headless
```

See [`../planning/run_state.md`](../planning/run_state.md) for the full
state-file schema. Every subagent launch passes the workspace path so the
subagent reads its skill's `STATE_<skill>.md` and inherits mode.

## Mode behaviors

### Interactive (default)

Interactive mode is collaborative — the user is pairing on the work. Follow
the voice and message-timing rules in [`interactive_ux.md`](interactive_ux.md):
a collaborative voice, a non-blocking orientation at the start, and a
self-contained re-orientation at every pause.

Routine pause gates:

| Skill / step | AskUserQuestion options |
|---|---|
| `/develop` Plan Review (after Design, Step 7) | `Proceed` / `Revise — I want changes` / `Stop` |
| `/develop` Review (Step 10) | `Fix all and continue` / `Let me pick which to fix` / `Skip fixes` |
| `/develop` Commit & push (Step 11) | `Commit and push` / `I'll review the diff first` / `Commit only (no push)` |
| `/develop` After MR creation (before Step 12) | `Yes — monitor pipelines` / `No — I'll check on it myself` |
| Any skill, workspace cleanup at successful end | `Clean up workspace` / `Keep workspace` |

The pre-code experience is a **single routine gate — Plan Review** — not a
string of confirmations. Steps 1–7 (Jira → Validate → Model Assessment → Plan
→ Research → Architecture → Design) run without a routine pause; the plan and
the stubbed skeletons are presented together at Plan Review, where the user
can question or redirect before any code is written.

**Conditional decision-points** still fire when triggered (they are not
routine gates and are not removed):
- **Validate blocker** — a real blocker always stops (see Cross-mode rules).
- **Model Assessment** (Step 3) — may emit an Opus recommendation.
- **Safe-update-strategy choice** (Step 4) — when the ticket modifies existing
  behavior without naming a strategy, ask which to use (the choice shapes
  Architecture, so it cannot wait for Plan Review).
- **`NEEDS_DECISION`** from any subagent — ask in chat.

### Guided

Guided is "trust the plan — build it, check with me before you push." It runs
Steps 1–10 (through Review) without pausing, **including skipping the Plan
Review gate**. Then:

1. **Commit & push (Step 11):** present a summary of the work done plus the
   diff, and confirm before commit and push. Use the lighter collaborative
   re-orientation in [`interactive_ux.md`](interactive_ux.md).
2. **After MR creation:** ask whether to monitor the pipeline — same gate as
   interactive.

Workspace cleanup at end runs as in interactive mode (single prompt).
Conditional decision-points (Validate blocker, safe-update-strategy choice,
`NEEDS_DECISION`) fire as in interactive.

### Auto

No `AskUserQuestion` calls. Runs all steps unattended. Stops on errors or
`NEEDS_DECISION` with a partial summary (a user is watching locally; they
can pick up from there). Commit, push, monitor the pipeline, and merge
automatically. Workspace cleanup runs automatically at successful end.

### Headless

No `AskUserQuestion` calls. Runs all steps unattended. On `NEEDS_DECISION`,
follows the three-tier escalation in
[`headless_escalation.md`](headless_escalation.md). Workspace persistence
and resume are handled by the shared-workspace-repo sync (see
[`headless_escalation.md`](headless_escalation.md), "Workspace lifecycle",
and [`../planning/workspace_sync.md`](../planning/workspace_sync.md)) — no
feature-branch-specific handling needed. Workspace cleanup runs
automatically at successful end.

## Status updates vs. documentation

Two different things get written during a run; they route differently.

- **Status updates** — progress notes with no lasting record value ("MR
  created", "development complete, monitoring the pipeline", "tests green").
  - `interactive` / `guided`: report to **chat**. The user is present.
  - `auto` / `headless`: post to the **external interface** (Jira / GitHub) —
    that record IS the communication channel when no user is watching.
- **Documentation** — requirement changes and implementation decisions that
  complete the ticket's contract: an under-specified requirement resolved
  during work ("associated User with class A, not B"), an addition beyond the
  original spec, or a Bug's root cause. These are **posted to Jira in every
  mode** — they are a lasting record, not status.
  - A process note (e.g., "moved the spec to match conventions after review")
    is neither, and is not posted — **unless** it deviates from the documented
    requirements/AC, in which case it is documentation.

Each step that would post to Jira/GitHub branches on this distinction: status
→ chat in interactive/guided (external in auto/headless); documentation →
Jira in every mode.

## `NEEDS_DECISION` behavior by mode

| Mode | Behavior |
|---|---|
| `interactive`, `guided` | Escalate inline via `AskUserQuestion`. |
| `auto` | Stop with partial summary. User reads output, decides next step. |
| `headless` | Three-tier escalation per [`headless_escalation.md`](headless_escalation.md). |

## Shared-workspace-sync access behavior by mode

Mode also governs how a shared-workspace-sync access failure degrades —
see [`../planning/workspace_sync.md`](../planning/workspace_sync.md)
§"Access-failure degradation" for the per-mode table (same
interactive/guided-ask vs. auto/headless-silent-continue split used
throughout this file).

## Resume behavior (all modes)

A resume — either ` -p --resume`, or re-invoking `/develop [ticket]`
when a `.workspace/[ticket]/STATE_develop.md` already exists — begins with
two actions before any other work:

1. **Read `STATE_<skill>.md`.** Apply the trust/verify check in
   [`../planning/run_state.md`](../planning/run_state.md) ("Trusting
   completed steps") to anything in `completed_steps`; begin from the first
   surviving `pending_steps` entry.
2. **Fetch ticket comments via MCP and diff.** Call
   `mcp__jira__get_issue` (and `mcp__github__get_discussions` for `/develop`
   sessions with an open MR); compare against `last_known_comments` /
   `last_known_discussions` in `CONTEXT.md`. Surface any deltas — a comment
   added between sessions may change what needs to happen next.

3. **If the workspace folder is missing locally** (new machine, or a prior
   session cleaned it up), the startup pull in
   [`../planning/workspace_sync.md`](../planning/workspace_sync.md)
   recovers it from the shared workspace repo — no special-casing needed
   beyond the pull every orchestrator already does at Step 1 of this list.

## Workspace cleanup at successful completion

When a skill reaches successful end-of-task, clean up the workspace:

| Skill | Cleanup point | Interactive prompt? |
|---|---|---|
| `/planning` | After all child tickets created in Jira | yes (auto/headless: skip prompt) |
| `/develop` | After MR merged (confirmed via `mcp__github__get_mr`) | yes (auto/headless: skip prompt) |
| Other skills | Skill-specific; see each skill's final step | yes |

**Precondition**: per [`../planning/workspace_sync.md`](../planning/workspace_sync.md)
§"Never delete without a confirmed push", push the workspace first and
only proceed if it returns `status: "ok"` (or there was nothing pending to
push). If the push fails or reports `no_remote_repo_access`, skip the
deletion and say so — the local folder is the only copy at that point.

Once confirmed, cleanup deletes the local workspace folder:

```
rm -rf .workspace/{ticket}/
```

Unlike local deletion, this isn't the end of the record — the shared
workspace repo retains the full history, so anyone who later needs to see
what a completed ticket's plan.md or research.md said can still pull it
down; there's just no more active work to resume.

## Cross-mode rules

- **`NEEDS_DECISION`** from any subagent — escalate per the mode-specific
  table above.
- **Blockers found in Validate** always stop, regardless of mode — report
  the blocker and let the user (or in headless, the escalation path)
  decide whether to proceed.
- **Architectural changes uncovered mid-Code/Review** route through the
  pipeline's NEEDS_DECISION rules in every mode.

## Related

- [`../planning/workspace_sync.md`](../planning/workspace_sync.md) — the
  shared-workspace-repo pull/push protocol; the source of the
  `no_remote_repo_access` degradation table and the cleanup precondition
  above.
- [`headless_escalation.md`](headless_escalation.md) — three-tier
  `NEEDS_DECISION` escalation contract and workspace lifecycle (headless
  mode only).
- [`../../skills/develop/SKILL.md`](../../skills/develop/SKILL.md) — the
  `/develop` launcher and dispatch logic.
- [`../../skills/develop/pipelines/develop.md`](../../skills/develop/pipelines/develop.md)
  — the per-step pipeline file that honors these pause points and the
  workspace lifecycle.
- [`interactive_ux.md`](interactive_ux.md) — collaborative voice and
  message-timing rules for `interactive` / `guided` gates.
- [`../planning/run_state.md`](../planning/run_state.md) — `CONTEXT.md` /
  `STATE_<skill>.md` schema (per-skill state files plus shared carry-forward
  context, for workspaces multiple skills touch).
- [`../../headless/autonomy-preamble.txt`](../../headless/autonomy-preamble.txt)
  — system-prompt addendum loaded via ` -p`.
- [`../../usage.md`](../../usage.md) — ` -p` invocation reference.
