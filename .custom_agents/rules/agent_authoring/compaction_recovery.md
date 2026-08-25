---
last_reviewed: 2026-05-26
---

# Compaction recovery

How an orchestrator recovers when a subagent returns an error or a truncated
response (typically because the subagent's context filled up and was
compacted mid-run).

## The pattern

When a subagent returns an error or appears truncated:

1. **Check for progress on disk.** Look at:
   - Workspace files the subagent should have written
     (`[workspace]/plan.md`, `[workspace]/research.md`, etc.)
   - Source files modified (`git status`, `git diff --stat`)
   - `.-touched-files` entries for the current run
2. **If progress was made:** launch a new subagent from where the previous
   one left off. Reference the completed artifact and list the remaining
   work explicitly in the new prompt. Keep the same model — the previous
   attempt was making headway; it just needed more context.
3. **If NO progress was made:** apply the **model escalation** rule below
   (try once with a stronger model), then if that also fails, stop and
   report.

## Why

Compaction is invisible to the orchestrator — it sees a malformed return,
not a "context full" signal. Without this pattern, the orchestrator either
retries blindly (and burns context retracing work) or gives up (and loses
the partial output). Checking the workspace turns compaction into a clean
resume point.

## Model escalation on no-progress compaction

A subagent that compacted with **no progress on disk** spent its entire
window thrashing — it couldn't form a plan, couldn't get started, couldn't
write the first artifact. That's a reasoning-capability signal, not a
context-volume signal. A stronger model genuinely helps here. Progress
compactions don't get this treatment — they just need more context.

### The ladder

```
declared model          escalates to
─────────────────       ────────────────
haiku                   sonnet
sonnet                  opus
opus                    stop and report (already at top)
```

### Rules

1. **No-progress check first.** Verify the subagent really produced
   nothing — no workspace file, no `git diff`, no `.-touched-files`
   additions. If there is *any* partial artifact, that's the "progress"
   case; relaunch on the same model.
2. **One escalation per subagent type per pipeline run.** Track
   `escalation_attempted` in structured context. If a subagent already
   escalated once and compacts again with no progress, stop and report —
   the task is too large for any single subagent, regardless of model.
   Splitting beats further escalation.
3. **Override the model at launch.** The `Agent` tool's `model` parameter
   takes precedence over the agent file's frontmatter. Pass the next-tier
   model when relaunching:

   ```
   Agent(
     description: "...",
     subagent_type: "<same agent>",
     model: "opus",         # explicit override for the retry
     prompt: "..."
   )
   ```

4. **Same prompt structure, smaller scope if possible.** When escalating,
   it's fine to also narrow the prompt (fewer files, fewer reference
   reads) — both levers compound.

## Reporting escalations

Orchestrators surface escalations in the pipeline-end summary so the
user can correlate cost with what actually happened. Include a one-line
note when any escalation occurred:

```
Pipeline Complete: MDP-12345
  ...
  Notes: 1 subagent escalated to opus on retry (planning_brief — no
         progress on first attempt)
```

When no escalations occurred, omit the line entirely — silence is the
default.

## What NOT to do

- Don't relaunch the same subagent with the same prompt — it will hit the
  same context wall.
- Don't accumulate the subagent's partial output in your own context and
  try to compose the missing parts yourself. The orchestrator's job is
  delegation, not implementation.
- Don't escalate past one step. If sonnet → opus → no progress, the task
  is too big — split it or stop.
- Don't escalate on progress compactions. Same model + new context window
  succeeds; escalating just spends more for no benefit.

## Related

- [`workspace_output.md`](workspace_output.md) — the workspace-output
  pattern that makes compaction recovery possible (durable artifacts on
  disk, short summaries in return values).
- Subagent model + tool allowlists live in each agent file's frontmatter
  (`./agents/<name>.md`). The `Agent` tool's `model` parameter
  overrides the frontmatter at launch time, which is how escalation is
  implemented.
