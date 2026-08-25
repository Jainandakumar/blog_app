# Cost Control & Model Assessment — Decisions

Source of truth for the choices behind the model-escalation feature.
Update this file when scope, placement, thresholds, or wording change;
then update the rule and skill files to match. This file is read by
maintainers (via `/author`), not by skills at runtime.

## Why this exists

Anthropic Console spend rose ~5× over two weeks in May 2026. Mitigation:
default the fleet to Sonnet (via Kandji managed settings, plus a
project-level `"model": "sonnet"` failsafe in `./settings.json`),
and let reasoning-heavy skills recommend the user manually escalate
to Opus for genuinely complex work.

The single change in the instruction layer: selected skills add a
one-step **model assessment** to their pipeline. The assessment runs
in the orchestrator's context (Sonnet by default), uses heuristics from
`./rules/develop/model_assessment.md`, and — only in interactive
or guided mode — prompts the user to run `/model` and pick Opus before
continuing.

## Scope: which skills run the assessment

| Skill | Assessment? | Notes |
|---|---|---|
| `/develop` (standard) | yes | After Validate, before Plan |
| `/develop` (fix mode) | yes | After Read Feedback, before Evaluate |
| `/develop` (spike mode) | yes — always recommend | Spikes are definitionally heavy reasoning; no heuristic — always recommend Opus |
| `/planning` | yes | After Feature fetch, before Research |
| `/code-review` | yes (lighter) | At start; recommends if diff exceeds threshold |
| `/author` | no | Mostly small, mechanical edits |
| `/document` | no | YARD application is mechanical |
| `/jira` | no | Light fetch + status work |
| `/github` | no | Read-only status checking |
| `/setup` | no | Configuration, no reasoning |

## Placement: where the assessment fires

The principle: **after enough context to make the call, before the
heaviest-reasoning step.** Most pipelines have a single sweet spot.

| Skill | Position | Why |
|---|---|---|
| `/develop` | Between Validate (Step 2) and Plan (Step 3) | Validate provides ticket type/scope; Plan is the highest-reasoning step. Plan  from Opus if escalated. |
| `/develop fix` | Between Read Feedback (Step 1) and Evaluate (Step 2) | Feedback content is in hand; Evaluate is the planning step for fixes. |
| `/develop spike` | At pipeline start | Spikes always recommend — no heuristic needed. |
| `/planning` | Between Feature fetch (Step 1) and Research (Step 2) | Feature description visible; Research + Breakdown are the heavy steps. |
| `/code-review` | At pipeline start, after diff scan | Diff size known upfront. |

## Mode interaction

| Mode | Assessment runs? |
|---|---|
| `interactive` | Yes |
| `guided` | Yes |
| `auto` | **No** — operator chose the model at launch |
| `headless` | **No** — operator chose the model at launch |

Auto and headless skip because there is no user-side `/model` switch
available mid-run; the operator (or ` -p` invocation) sets the
model at launch.

## Skip if already on Opus

In addition to the mode gate, the assessment also skips when the
orchestrator detects it's already running on Opus. Recommending Opus
to a session that's on Opus is just noise. Detection is best-effort
via the system-prompt model identifier; a mid-session `/model` switch
from Opus to Sonnet may leave the check stale, but the failure mode
is benign (task continues on whatever's actually active).

## Trigger heuristics (current — bar is deliberately low)

The assessment recommends Opus when **any** of the following holds.
This bar is intentionally low — when in doubt, recommend. The cost
of an unnecessary Opus run on a small task is small; the cost of
doing complex work silently on Sonnet is significant.

| Signal | Source | Threshold |
|---|---|---|
| File count touched | Validate scope / Plan output | ≥ 5 files |
| Layers touched (model + controller + view + job, etc.) | Plan output | ≥ 3 layers |
| Cross-engine or cross-namespace work | Plan output / Validate notes | any |
| New architectural pattern / new abstraction | Plan / Validate notes | any |
| Ambiguous or contested spec | Validate output | any |
| Refactor of code with high coupling | Research output (if available) | any |
| Spike with multiple research questions | spike_plan output | > 2 questions |
| Code review diff size | `git diff --stat` | > 200 changed lines OR > 5 files |

## Special cases

### `/develop` spike pipeline

Always recommend Opus at pipeline start. No heuristic. Spikes are
research-heavy by definition; the cost-of-skipping is the largest in
this family of work.

### `/develop` fix pipeline

Apply heuristic. Some fixes are typo-level; others are
architectural-feedback rewrites. The signal comes from the feedback
content read in Step 1.

## Prompt template (UX — exact wording skills emit)

> *"This task — [restated scope in 1 sentence] — involves [reasoning load: e.g., cross-engine refactor, 8+ files, ambiguous spec]. Recommend switching to Opus before continuing.*
>
> ***How to switch:*** *type `/model` (no argument). A picker appears. Select 'Opus' from the list. If Opus is already your current default (the picker shows 'Default (Currently Opus)'), no switch needed — just reply 'continue'.*
>
> *To proceed on Sonnet anyway, reply 'continue' now."*

Rationale for `/model` no-arg: works in every IDE (VS Code picker,
RubyMine, terminal). `/model opus` works in terminal but not VS Code
picker UI. One instruction handles both.

## How to revise

1. Edit the relevant section of this file (scope / placement /
   heuristics / wording).
2. Edit `./rules/develop/model_assessment.md` to match.
3. If placement changes, edit the relevant skill / pipeline files.
4. Append an entry to History below.

Skills automatically read the rule each time the assessment runs;
no skill-file edits needed for threshold tuning alone.

## History

- **2026-05-28** — Initial design. Thresholds set deliberately low
  ("when in doubt, recommend"). Anticipated future tightening once
  we observe how often the assessment fires unnecessarily — likely
  candidates: files ≥ 8 (instead of ≥ 5), spike-questions ≥ 4
  (instead of > 2), diff > 400 lines (instead of > 200).
- **2026-05-28** — Added "skip if already on Opus" model gate.
  Recommendation to a session that's already on Opus is noise; the
  gate suppresses it. Detection is best-effort via system-prompt.
- **2026-06-09** — Added subagent **downgrade** mechanism (asymmetric
  to upgrade per design principle 2). Initial set: `jira_fetch`,
  `planning_architecture_overview` (`[sonnet, haiku]`);
  `interactive_debug`, `spike` (`[opus, sonnet]`). Decision-making
  uses prior-subagent-recommends pattern via `next_agent_hint` in
  the workspace-output return value — the prior subagent has better
  context than the orchestrator to assess the next step's complexity.
  Fallback: orchestrator decides for first-step agents
  (`validate`, `plan` in fix mode, `jira_fetch`, `spike_plan`).
  Other agents (code_*, design, test, etc.) intentionally do NOT
  declare `availableModels` — they need full reasoning for correctness.
