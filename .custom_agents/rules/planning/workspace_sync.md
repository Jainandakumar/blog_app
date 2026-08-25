---
last_reviewed: 2026-08-05
---

# Shared workspace sync

How `.workspace/{ticket}/` is kept in sync with the shared `ai/workspaces`
GitHub project, via the generic `mcp__github__sync_workspace_pull` /
`mcp__github__sync_workspace_push` tools. This lets one developer plan a
ticket, another develop it, and a third review it, all sharing the same
plan.md / research.md / CONTEXT.md / STATE_<skill>.md / attachments.md — without a local clone
of `ai/workspaces` and without `.workspace/` leaving ``'s own
`.gitignore`.

Read by every orchestrator skill (via `run_state.md`, which every skill
already reads) and by any agent that might write sensitive content into a
workspace file.

## Ticket-validity gate

Sync only applies to a real Jira ticket key. If the ticket key starts with
`LOCAL-` (the existing no-real-ticket convention) or `RESEARCH-` (a
topic-mode `/research` workspace with no real ticket), skip sync entirely —
no pull, no push, in either direction. The workspace stays purely local.

## Path construction

The MCP tools are generic (`local_dir` / `remote_path`, no ticket concept
of their own). The orchestrator constructs both paths itself:

- `local_dir` = `.workspace/{ticket}`
- `remote_path` = `{project-name}/{ticket}`, where `{project-name}` is the
  last path segment of `project_path` in `./github.json` (e.g.
  `"app/"` → ``) — not a separately configured value.

## Cross-ticket read-only pulls

The default pattern above is a ticket syncing its own workspace both ways.
A skill may also pull a **different** ticket's workspace as one-time,
read-only reference context — e.g. `/develop` pulling a Story's parent
Feature's `.workspace/{feature}/` (built by `/planning`) for its
`codebase_research.md` or `tech_design.md`, per
[`../../skills/develop/pipelines/steps/01_jira.md`](../../skills/develop/pipelines/steps/01_jira.md).
Same tool, same `local_dir`/`remote_path` construction (using the *other*
ticket's key), with two invariants that don't apply to the default
pattern: never call `sync_workspace_push` on it, and never delete it as
part of the pulling ticket's own workspace cleanup — its lifecycle belongs
to the ticket it was pulled from, not the one reading it.

## When pull/push fire

No new pipeline phases — these hook into lifecycle points every skill
already has, per `run_state.md`:

- **Pull**: at orchestrator startup, immediately before reading
  `CONTEXT.md` / `STATE_<skill>.md`. Covers both a fresh run and a
  `--resume` — the same hook handles picking up someone else's
  in-progress ticket.
- **Push**: immediately after each step's `STATE_<skill>.md` update.
- **Push before workspace cleanup**: see "Never delete without a
  confirmed push" below.

Call the tools directly — this is orchestrator-inline logic, not a
subagent. No-conflict syncs (the common case) cost nothing beyond the two
tool calls.

## Handling the result

`sync_workspace_pull` returns `files_pulled`, `files_deleted_locally`, and
`files_conflicted`.

- If `files_conflicted` is non-empty, `files_pulled` is non-empty
  (something remote-originated actually merged in), or
  `files_deleted_locally` is non-empty (a remote deletion propagated
  here), launch the `workspace_sync_resolve` agent
  (`./agents/workspace_sync_resolve.md`) with all three lists. Re-run
  `sync_workspace_push` after it returns.
- Otherwise (nothing changed remotely — the overwhelming common case),
  continue immediately. No agent, no extra reasoning.
- **Always log `files_deleted_locally` in the step summary**, even when
  it's the only non-empty list — a deletion is worth a visible line
  regardless of whether it also triggers the resolve agent.
- **If `CONTEXT.md`, any `STATE_*.md`, `plan.md`, or `research.md` appears
  in `files_deleted_locally`**, treat it as more than a log line: those
  files are load-bearing for the pipeline's own resume logic, so a silent
  deletion can mean a later step runs against context that's no longer
  there. Surface this explicitly to the user (interactive/guided) or as a
  documentation-worthy note in the run summary (auto/headless) rather than
  continuing as if nothing happened.

`sync_workspace_push` returns `status: "conflict"` if its own re-pull
surfaces a new conflict. Treat this exactly like a pull-time conflict —
route through `workspace_sync_resolve`, then push again. Never let the
push tool guess a resolution.

## Never delete without a confirmed push

Workspace cleanup (`rm -rf .workspace/{ticket}/` at successful skill
completion, per `pipeline_modes.md`) requires a preceding
`sync_workspace_push` that returns `status: "ok"` — or confirmation there
was nothing pending to push. If push fails or returns
`no_remote_repo_access`, **skip the deletion** and say so in the run
summary. The local folder is the only copy in that case; losing it is
strictly worse than a stale ticket folder sitting on disk. This check
ignores `.secrets` (see below) — that file is never pushed by design, so
its presence never blocks cleanup.

## Access-failure degradation

`no_remote_repo_access` (missing `workspace_repo_project_id` in
`github.json`, or the workspace project unreachable) is a normal status,
not an error:

| Mode | Behavior |
|---|---|
| `interactive`, `guided` | Ask via the `setup_check` agent's Fix-now/Skip pattern ("workspace sync isn't reachable — fix now or skip?"). Cache the answer in `STATE_<skill>.md` for the rest of the session — don't re-ask every step. |
| `auto`, `headless` | Continue without syncing. Log one line in the pipeline-end summary. No prompt. |

## Secrets in the workspace

`.workspace/` content is now version-controlled remotely. Any agent that
would otherwise write a secret-shaped value (a token, a temp password,
anything sensitive) into a normal tracked file writes it to `.secrets`
instead — a flat, unstructured, dot-prefixed file (same convention as
`.env` / `.netrc`), always excluded from sync by the MCP tools' built-in
defaults. No configuration needed to get this exclusion.

- Prefer not persisting a secret at all — use it in-session and move on.
  Write to `.secrets` only when a later step genuinely needs it again.
- A synced file may reference `.secrets` by name ("API key: see
  `.secrets`"); never inline the value itself into synced content.
- If a synced file references `.secrets` and it's missing locally (new
  machine, a different developer resumed the ticket, or it was simply
  never written) — that's expected, not an error. Ask the user for the
  value; it was never meant to travel.
- If an agent writes to `.secrets`, it says so plainly: the value is
  local-only, won't sync, and won't survive workspace cleanup — if it
  matters beyond this session, the user needs to keep it somewhere else.

## Binaries in the workspace

Binaries downloaded into the workspace (Jira attachments, video frames)
are transient processing intermediates by default — delete once the
one-shot analysis producing them is done, unless there's a genuine reason
to keep the file for later. Anything retained must be named in some
markdown file in the workspace, so nothing sits there un-referenced. This
is what lets the sync tools skip file-type awareness entirely: a retained
binary just syncs like any other file once it's referenced.

## Related

- [`run_state.md`](run_state.md) — the `CONTEXT.md`/`STATE_<skill>.md`
  lifecycle this hooks into.
- [`../develop/headless_escalation.md`](../develop/headless_escalation.md)
  — headless mode's workspace persistence, now provided by this sync
  mechanism instead of the retired in-branch force-commit dance.
- [`../develop/pipeline_modes.md`](../develop/pipeline_modes.md) —
  workspace cleanup at successful completion.
- `./agents/workspace_sync_resolve.md` — the conflict/validation
  agent this rule routes to.
- `./agents/setup_check.md` — the Fix-now/Skip pattern reused for
  the interactive degradation path.
