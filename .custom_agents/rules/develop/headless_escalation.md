---
last_reviewed: 2026-08-05
---

# Headless escalation and workspace lifecycle

Contracts that apply only in `headless` mode — three-tier `NEEDS_DECISION`
escalation, and how the shared-workspace-repo sync (see
[`../planning/workspace_sync.md`](../planning/workspace_sync.md)) makes
`--resume` work across sessions. The four-mode framework, mode detection,
and `--resume` ticket-comment-check live in
[`pipeline_modes.md`](pipeline_modes.md).

## Three-tier `NEEDS_DECISION` escalation

When a subagent returns `NEEDS_DECISION` in headless mode and the
orchestrator cannot resolve it from context or rules:

### Tier 1 — Orchestrator resolves from context

Read the ticket, the workspace artifacts (`CONTEXT.md`, `STATE_<skill>.md`,
`plan.md`, `research.md`, etc.), and the relevant project rules. If a
reasonable answer exists, choose it, log to `CONTEXT.md` under
`recent_decisions:`, and continue.

### Tier 2 — Escalate and wait

If Tier 1 fails, write `.workspace/{ticket}/state/escalation.json`:

```json
{
  "ticket": "MDP-NNNNNN",
  "skill": "develop",
  "session_id": "<_CODE_SESSION_ID>",
  "question": "<the NEEDS_DECISION text>",
  "context_files": [".workspace/MDP-NNNNNN/CONTEXT.md", ".workspace/MDP-NNNNNN/STATE_develop.md", "..."],
  "posted_at": "<ISO-8601 UTC>",
  "wait_until": "<posted_at + 30 minutes>"
}
```

Then stop. The session can be `--resume`'d by the external watcher with
the user's reply (written to `state/teams-reply.md` before resume) or
with a timeout signal.

The 30-minute default is configurable per skill — a skill may set its
own `wait_until` offset in its own `STATE_<skill>.md` if its work has a
different expected cadence.

### Tier 3 — Blocker (on resume after timeout)

When resumed with `state/teams-reply.md` absent and
`state/escalation.json` showing `wait_until` already passed:

1. Save all state to `.workspace/{ticket}/`.
2. Write `state/blocker.md` with full context — what was attempted,
   what blocked, what was tried.
3. Push the workspace per [`../planning/workspace_sync.md`](../planning/workspace_sync.md)
   so `blocker.md` and everything else is durable before exiting — this is
   the same push every step already does, just triggered explicitly here
   since a blocker exits before the normal step-completion point.
4. Update the Jira ticket with extended blocker details via
   `mcp__jira__add_comment`.
5. Exit.

### Mode-specific behavior on `NEEDS_DECISION`

| Mode | Behavior |
|---|---|
| `interactive`, `guided` | Escalate inline via `AskUserQuestion`. |
| `auto` | Stop with partial summary. User reads output, decides next step manually. |
| `headless` | Three-tier escalation above. |

## Workspace lifecycle

Workspace persistence and cross-session recovery are handled entirely by
[`../planning/workspace_sync.md`](../planning/workspace_sync.md) — pushing
to the shared `ai/workspaces` repo after every step already means there is
nothing extra to preserve at a blocker (beyond the explicit push in Tier 3
above, since a blocker exits before the normal step-completion point), and
`--resume` recovering state is just the normal startup pull, on any
machine, regardless of whether the local working tree still has the
feature branch checked out.

This replaces an earlier design that force-committed `.workspace/{ticket}/`
into the feature branch itself (before a blocker, and again before the
MR-creation push) and recovered it via `git checkout HEAD~1`. That existed
only because there was no other persistence mechanism; it also meant every
headless `/develop` run added two throwaway commits to feature-branch
history. Superseded now that the shared workspace repo covers the same
need without touching the feature branch at all.

**`/planning` no longer needs an exception.** The old force-commit
mechanism required a branch to push to, which a Feature-level `/planning`
run doesn't have — that's why an earlier version of this rule exempted it
from blocker preservation. The shared workspace repo has no such
requirement (it's a separate project, not the feature branch), so
`/planning` gets full headless blocker preservation and resume like every
other skill.

## Related

- [`../planning/workspace_sync.md`](../planning/workspace_sync.md) — the
  shared-workspace-repo pull/push protocol that now provides all of this
  rule's workspace persistence and resume behavior.
- [`pipeline_modes.md`](pipeline_modes.md) — mode taxonomy, detection,
  per-mode pause behavior, `--resume` ticket-comment-check, workspace
  cleanup at successful completion.
- [`../../headless/autonomy-preamble.txt`](../../headless/autonomy-preamble.txt)
  — system-prompt addendum that codifies these contracts for the
  autonomous agent.
- [`../meta/decision_log.md`](../meta/decision_log.md) — entry
  "2026-05-27 — Four-mode pipeline taxonomy + three-tier headless
  escalation" explains the design.
