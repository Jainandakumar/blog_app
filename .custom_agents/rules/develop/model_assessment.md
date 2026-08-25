---
last_reviewed: 2026-05-28
---

# Model assessment

Skill-level assessment step that recommends the user escalate to Opus
when the work appears to need it. Runs in the orchestrator's context
on whatever model is currently active (typically Sonnet from the
managed default).

For the rationale, scope decisions, and revision history, see
[`../../skills/author/cost_control_decisions.md`](../../skills/author/cost_control_decisions.md).

## When the assessment runs

Skills that include this step in their pipeline (see decisions doc for
the canonical list):

- `/develop` (standard): after Validate, before Plan
- `/develop fix`: after Read Feedback, before Evaluate
- `/develop spike`: at pipeline start (always recommend, no heuristic)
- `/planning`: after Feature fetch, before Research
- `/code-review` branch-review pipeline: at pipeline start (diff-size heuristic)
- `/code-review` Feature-review pipeline: before launching coverage
  batches (child-ticket-count / candidate-file-count heuristic)

## Mode gate

Skip the assessment in `auto` and `headless` modes — the operator (or
` -p` invocation) already chose the model at launch. There is
no user-side `/model` switch available mid-run in those modes.

Run the assessment in `interactive` and `guided` modes only.

## Model gate

Skip the assessment if the orchestrator is **already running on Opus**.
The recommendation would be pointless noise. Check the system prompt
("You are powered by the model named ...") — if it identifies Opus, skip
all heuristics and continue silently to the next step.

This check is best-effort: if the user invoked `/model` mid-session to
switch from Opus to Sonnet, the system prompt may still read "Opus" and
the assessment will incorrectly skip. The failure mode is benign — the
task continues on whatever model is actually active, with no
recommendation. If quality suffers, the user can switch back via
`/model` at any point.

## Heuristics

Recommend Opus when **any** of these holds. The bar is deliberately
low — when in doubt, recommend.

| Signal | Source | Threshold |
|---|---|---|
| File count touched | Validate scope or Plan output | ≥ 5 files |
| Layers touched (model + controller + view + job, etc.) | Plan output | ≥ 3 layers |
| Cross-engine or cross-namespace work | Plan / Validate | any |
| New architectural pattern / new abstraction | Plan / Validate | any |
| Ambiguous or contested spec | Validate | any |
| Spike with multiple research questions | spike_plan | > 2 questions |
| Code review diff size | `git diff --stat` | > 200 lines OR > 5 files |
| Refactor of high-coupling code | Research (if available) | any |
| Feature-review batch/file scale | `feature_review_fetch` return | > 8 child tickets OR large `candidate_file_count` |

For spike pipelines: skip the heuristic entirely — always recommend.

## What to do at the assessment step

1. **Check mode.** If `auto` or `headless`, skip. Continue to the next
   pipeline step silently.
2. **Check current model.** If the orchestrator is already on Opus,
   skip. Continue silently.
3. **Apply heuristics.** Compare collected context (validate output,
   plan output, diff size, etc.) against the signals above.
4. **If no signal triggers**, continue silently to the next step. Do
   not emit any prompt — silent passthrough is the default.
5. **If any signal triggers** (or the skill is the spike pipeline),
   emit the prompt below and wait for the user's reply before
   continuing.

## Prompt template

Emit verbatim, with the bracketed fields filled in:

```
This task — [one-sentence scope] — involves [reasoning load:
e.g., cross-engine refactor, 8+ files, ambiguous spec]. Recommend
switching to Opus before continuing.

**How to switch:** type `/model` (no argument). A picker appears.
Select 'Opus' from the list. If Opus is already your current
default (the picker shows 'Default (Currently Opus)'), no switch
needed — just reply 'continue'.

To proceed on Sonnet anyway, reply 'continue' now.
```

`/model` (no argument) works in every IDE  Code surface (VS Code
picker, RubyMine, terminal). `/model opus` works in terminal but not
in VS Code's picker UI. Use the no-argument form so the instruction
is universal.

## Handling the user's reply

- **User replies "continue"** (whether or not they switched the model):
  proceed to the next pipeline step.
- **User replies anything else**: treat as a follow-up instruction
  (their request might be to abort, adjust scope, etc.); handle per
  the orchestrator's normal user-input handling. Do not loop the
  assessment.

The orchestrator does not need to detect whether the switch actually
happened — `/model` is a  Code mechanism, not a skill operation.
The skill just continues; the next response runs on whatever model is
now active.

## Caveat — long sessions

When prompting for Opus on a long-running session (e.g., 200K+ tokens
into the conversation), include a one-line note that the switch
incurs a cache miss on the next turn. The reload is rarely
prohibitive for genuinely complex work, but flipping back and forth
mid-pipeline is wasteful.

Append to the prompt template when context is long:

> *Note: switching mid-session incurs a cache reload on the next turn
> — worth it for the rest of this pipeline, but avoid flipping back
> and forth.*

## Subagent model downgrade

The assessment above is about **upgrading the orchestrator** to Opus.
Subagents are handled separately and asymmetrically.

A subagent can be launched on a model **smaller** than its pinned
`model:` when:
1. The agent's frontmatter declares `availableModels:` listing the
   smaller model, AND
2. The work fits the smaller model's capabilities.

### Who decides — prior subagent recommends, orchestrator applies

The orchestrator doesn't have granular context to judge whether the
next subagent can be downgraded. The agent that just finished has
much better insight (actual file list, task complexity, research
findings).

**Primary**: prior subagent includes an optional `next_agent_hint`
line in its return value per
[`../agent_authoring/workspace_output.md`](../agent_authoring/workspace_output.md).
The orchestrator parses it and uses `Agent(model: ...)` on the next
launch if the target agent's `availableModels` permits.

**Fallback**: for first-step agents with no prior subagent
(`validate`, `plan` in fix mode, `jira_fetch`, `spike_plan`), the
orchestrator decides based on the original task.

**Override**: orchestrator may override either source if the user's
prompt specifies a model preference.

### When a hint should recommend downgrade

Mechanical / narrow-scoped work — downgrade is safe:
- Routine fetches, summarization of structured input, format
  translation, confirming patterns in known files, filling stubs
  where design is decided.

Keep the pinned model when:
- Code generation involves real decisions, cross-file understanding,
  judgment between options, conditional multi-step reasoning, or
  anything novel.

### Why upgrade is orchestrator-only and downgrade is subagent-only

The orchestrator does varied, routing-heavy work that  from
upgrading to Opus when the overall task is complex. Subagents do
scoped, focused work — many are overpinned at Sonnet for what's
mechanically a Haiku-appropriate task. The asymmetry: upgrade
broadens scope of reasoning; downgrade narrows it.

## Related

- [`../../skills/author/cost_control_decisions.md`](../../skills/author/cost_control_decisions.md) — design rationale, history, revision steps.
- [`pipeline_modes.md`](pipeline_modes.md) — four-mode framework. Auto + headless skip the assessment.
- [`../meta/decision_log.md`](../meta/decision_log.md) — historical context.
