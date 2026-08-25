# Brief dispatch — Step 7

How the planning orchestrator launches per-ticket brief subagents during
Step 7. Read this from `planning_instructions.md` Step 7.

## Per-type prompts

Use the prompt matching the ticket type from `[workspace]/breakdown.md`.

### Story or Bug

Launch a **general-purpose** Agent:

```
Read `./agents/planning_brief.md` for your instructions.

Ticket number: [N]
Type: [Story | Bug]
Title: [TITLE]
Description: [DESCRIPTION]
Target classes/methods: [FROM STEP 5]
Feature context: read [workspace]/feature_context.md for full description and context
Codebase research: [workspace]/codebase_research.md (read this file)
External research: [workspace]/external_research.md (read if exists)
Safe update strategy: [workspace]/safe_update_strategy.md (read this file if it exists)
Attachment descriptions: [workspace]/attachments.md (read this file if it exists)
Dependency briefs (read before writing this brief — these tickets must complete first):
- [workspace]/story_N_brief.md  ← include one line per dependency; omit this block if none
Workspace: [workspace path]
Local overrides: [relevant items from LOCAL.md]

Write brief to [workspace]/story_[N]_brief.md.
```

### Spike

Launch a **general-purpose** Agent:

```
Read `./agents/planning_brief.md` for your instructions — follow the Spike
section only.

Ticket number: [N]
Type: Spike
Title: [TITLE]
Description: [DESCRIPTION from breakdown]
Blocks: [list of ticket numbers this Spike blocks, or "none"]
Feature context: read [workspace]/feature_context.md for full description and context
Workspace: [workspace path]

Write brief to [workspace]/story_[N]_brief.md.
```

### DevOps Request

Launch a **general-purpose** Agent:

```
Read `./agents/planning_brief.md` for your instructions — follow the DevOps
Request section only.

Ticket number: [N]
Type: DevOps Request
Title: [TITLE]
Description: [DESCRIPTION from breakdown]
Feature context: read [workspace]/feature_context.md for full description and context
Workspace: [workspace path]

Write brief to [workspace]/story_[N]_brief.md.
```

## Parallelization

Launch up to 3 brief agents at a time. Each subagent has its own context,
so they won't interfere.

## Ordering

Process in dependency order. If ticket B depends on ticket A, write A's
brief first so B's agent can read it from the workspace. Independent
tickets can run in parallel.

**Example.** Given tickets 1-6 where 1, 3, 4 have no dependencies (Group A),
ticket 2 depends on ticket 1, and tickets 5, 6 depend on tickets 2 and 3:

- Round 1: Launch briefs for tickets 1, 3, 4 in parallel (3 agents).
- Round 2: Launch brief for ticket 2 (reads `story_1_brief.md`).
- Round 3: Launch briefs for tickets 5, 6 in parallel.
