# Step 1: Jira

**Runs only when `ticket_type: jira`.** For `ticket_type: local`, skip
this step and ask the user for requirements and a branch name instead.

Launch a general-purpose Agent:

```
"Read `./agents/jira_fetch.md` for your instructions.

Ticket: [TICKET_KEY]
Mode: [MODE]
Workspace: .workspace/[TICKET_KEY]"
```

The agent returns a structured summary including `type`,
`attachments_to_process`, `videos_to_process`, and `jira_context_file`.
Three things happen next, in your orchestrator context.

## Attachments processing

If `attachments_to_process` is non-empty, launch a general-purpose Agent:

```
"Read `./agents/planning_attachments.md` for your instructions.

Ticket: [TICKET_KEY]
Attachments: [pass through the list from jira_fetch's return]
Workspace: .workspace/[TICKET_KEY]

Download, review, and describe all attachments. Write descriptions to
.workspace/[TICKET_KEY]/attachments.md."
```

After it returns, append the descriptions from `attachments.md` into
`jira_context.md` so downstream subagents see them without an extra read.

## Video processing (Bug tickets with video attachments)

If `videos_to_process` is non-empty, launch a general-purpose Agent per
video. External tools (`ffmpeg`) are ensured by `/setup` — see
`./rules/agent_authoring/external_dependencies.md`.

```
"Read `./agents/bug_video_analysis.md` for your instructions.

Ticket: [TICKET_KEY]
Video attachment: {id, filename, content_type}
Workspace: .workspace/[TICKET_KEY]

Download, extract frames, analyze, and write findings to
`.workspace/[TICKET_KEY]/video_analysis.md`. Append to
`.workspace/[TICKET_KEY]/attachments.md`."
```

After it returns, append the video analysis into `jira_context.md`.

## Feature-workspace context (Story tickets only, orchestrator-inline)

If `parent_feature_key` is present, pull `.workspace/[parent_feature_key]/`
from the shared workspace repo
(`./rules/planning/workspace_sync.md`) — this is the `/planning`
session's own workspace for the parent Feature, and may hold
`codebase_research.md`, `tech_design.md`, or `external_research.md` with
context deeper than what fits in the ticket description. This is a
**cross-ticket, read-only pull**: never push it back, never delete it as
part of this ticket's workspace cleanup, and never treat it as this
ticket's own `STATE_develop.md`/workspace. Skip when `parent_feature_key`
is empty or when sync access is unavailable (per that rule's degradation
table).

If the pull succeeds and the directory has useful files, note their paths
in `jira_context.md` so Validate and Research can read them as optional
background — the ticket description remains the authoritative spec.

## Type-based routing

After Step 1 (and attachment/video processing) completes:

**Type = Spike:**

1. Update TodoWrite to the spike checklist:
   ```
   1. Jira (completed)
   2. Plan Research (pending)
   3. Conduct Research (pending)
   4. Report (pending)
   5. Follow-up Tickets (pending)
   6. Update Jira (pending)
   ```
2. Read `./skills/develop/pipelines/spike.md` instead of develop.md.

**Type = Bug:**

1. Update TodoWrite to the bug checklist (standard + cherry-pick):
   ```
   1. Jira (completed)
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
   14. Cherry-pick (pending)
   ```
2. Continue with `develop.md` — the Bug pipeline is the standard
   pipeline plus the Bug-specific cherry-pick section
   (`./skills/develop/pipelines/steps/14_bug_cherry_pick.md`)
   after Step 13.

**Type = Story / Task:** Continue with `develop.md` (no checklist
change).
