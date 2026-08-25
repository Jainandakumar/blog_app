---
last_reviewed: 2026-05-19
---

# Workspace-output pattern

Most subagents produce a durable artifact and report a short summary back to the
orchestrator. This rule defines the shape of that interaction so each agent file
doesn't restate it.

## The pattern

1. **Write the full output to the workspace file** specified in the agent's
   prompt (e.g., `[workspace]/plan.md`, `[workspace]/research.md`). The workspace
   path is provided in the prompt; never invent one.
2. **Answer the self-survey** per
   [`self_survey.md`](self_survey.md) — write your answers to
   `[workspace]/self_survey/{timestamp}_{agent}.md` before returning.
3. **Return a brief summary to the orchestrator** (3-5 lines). The summary should
   cover the key findings, decisions, or counts — not the full content.
4. **Do NOT** dump the full file contents into the return value. That defeats the
   purpose of writing to the workspace.
5. **Reference the file path** in the summary so the orchestrator (or a later
   agent) can read the artifact if it needs the detail.

## Why

The orchestrator's context fills up quickly when every subagent returns full
artifacts. Writing to the workspace keeps the artifacts durable across compaction
and lets the orchestrator pull only what it needs.

## Summary length guidance

| Output kind | Target return length |
|---|---|
| Plan, research, design, breakdown | 3-5 lines |
| Attachment descriptions, brief confirmations | 2-3 lines |
| Test results, evaluation triage | 3-5 lines, include pass/fail counts |
| Spike report, debug plan | 3-5 lines, include confidence level |

## Example return shape

```
Plan written to .workspace/MDP-NNNNNN/plan.md.
Touches: app/models/foo.rb (new), app/controllers/foos_controller.rb (modify).
6 tasks across 4 files. No blockers.
next_agent_hint: research=haiku (file list is concrete; just confirm patterns)
```

## What goes in the file vs what goes in the summary

| Detail | File | Summary |
|---|---|---|
| Per-task descriptions | Yes | No |
| Per-file paths and changes | Yes | Aggregate counts only |
| Acceptance-criteria checklists | Yes | No |
| Risks, blockers, NEEDS_DECISION items | Yes | Yes (so the orchestrator can route) |
| File path of the artifact itself | — | Yes |
| Model hint for the next agent | — | Optional — see below |

## Optional: model hint for the next agent

A subagent whose work informs the complexity of the next pipeline step
MAY include a `next_agent_hint` line in its return summary. Format:

```
next_agent_hint: <next_agent>=<model> (<one-sentence rationale>)
```

The orchestrator reads this when launching the next subagent. If the
hint suggests a downgrade and the target agent's `availableModels`
permits it, the orchestrator passes `model: <model>` on the
`Agent()` launch. If no hint is provided, or the target agent
doesn't permit the suggested model, the agent runs on its pinned
`model:` default.

Examples of when to provide a hint:
- After Plan: hint Research's model based on how concrete the task
  list is.
- After Research: hint Architecture's model based on whether the
  file map points at mechanical scaffolding or novel design.
- After Architecture: hint Design's model based on whether class
  skeletons have non-obvious method-signature decisions to make.

Don't provide hints speculatively. Only when the prior work
demonstrably informs the next step's complexity. See
[`../develop/model_assessment.md`](../develop/model_assessment.md)
§Subagent model downgrade for the full contract.
