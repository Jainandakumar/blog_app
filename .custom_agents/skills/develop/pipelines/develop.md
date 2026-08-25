# Standard Development Pipeline

Steps: Jira → Validate → Model Assessment → Plan → Research →
Architecture → Design → Code → Test → Review → Commit → Monitor → Merge.

**Step 1 (Jira) is already complete** when you start reading this file
— Setup launched the `jira_fetch` agent (or skipped it for
`ticket_type: local`). Use the Jira results as context for every
subagent.

Mode pause semantics live in
`./rules/develop/pipeline_modes.md`.

**Interactive / guided:** before Step 2, print the non-blocking start
orientation from `./rules/develop/interactive_ux.md` so the user knows
the flow (plan → stub → review → build → commit) up front.

## General rules

**Jira documentation rules** (apply only when `ticket_type: jira`):

These are **documentation** — a lasting record — posted to Jira in **every
mode**. They are distinct from **status updates** (progress notes like "MR
created" or "monitoring the pipeline"), which go to chat in interactive/guided
and to Jira/GitHub in auto/headless. See "Status updates vs. documentation" in
`./rules/develop/pipeline_modes.md`.

- **Document all deviations in Jira.** Any change from the original
  plan — additions, scope adjustments, more specific details
  discovered during work — gets a Jira comment. Multiple comments are
  fine.
- **Document additions not in the original spec.** If you implement
  anything beyond the original requirements, add a Jira comment listing
  what was added and why.
- **Bug tickets require root cause documentation.** For Bug tickets,
  document in a Jira comment:
  1. **What broke:** the symptom and affected functionality.
  2. **Why it broke:** root cause in the code. Identify the specific
     code change that introduced the bug using `git log` / `git blame`
     (include the commit hash and ticket number).
  3. **The fix:** what was changed to resolve it and why.
  4. **The code change that caused it:** reference the commit (e.g.,
     "Introduced in abc1234 MDP-222222 — that commit changed X which
     broke Y").
- **Absorb minor scope creep when possible.** If you discover missing
  requirements that are completable and testable within this ticket,
  do the work. But first check sibling tickets under the parent
  (Step 2 covers this at the start; apply the same logic if discovered
  later).
- **If blocked by a dependency:** find or create the blocking ticket,
  link it as a dependency on the current ticket, add a comment
  explaining the blocker, and stop development.

## Context passing

Between steps, maintain a structured summary (not full prose):

```
ticket: MDP-12345
ticket_type: jira | local
type: Story
branch: MDP-12345_add_validation
workspace: .workspace/MDP-12345/
requirements: [1-2 sentence summary]
criteria: [acceptance criteria list]
safe_update_strategy: [strategy type and toggle name, if applicable]
blocker_status: [all clear, or list of unresolved blockers]
functional_area: [Jira Functional Area value — feature-docs anchor, or empty]
jira_context: [workspace]/jira_context.md
local_overrides: [relevant items from LOCAL.md for this subagent's task]
validation_results: [brief summary, or "see [workspace]/validation.md"]
plan: [task list, or "see [workspace]/plan.md"]
files_found: [from research, or "see [workspace]/research.md"]
files_created: [from architecture]
files_modified: [from code]
```

Update after each step. Pass the current version to each subagent.

---

## STATE_develop.md update protocol

After every step completes, follow the full "After every step completes"
protocol in `./rules/planning/run_state.md` — update
`[workspace]/STATE_develop.md` (and `CONTEXT.md`, if the step produced a
decision or note worth another skill seeing) **and push it** to the shared
workspace repo (`./rules/planning/workspace_sync.md`); the push is
part of that protocol, not a separate step. Inline orchestrator work — not a
TodoWrite item.

---

## Step 2: Validate

See [`steps/02_validate.md`](steps/02_validate.md).

---

## Step 3: Model assessment

Between Validate and Plan, apply the model assessment per
[`../../../rules/develop/model_assessment.md`](../../../rules/develop/model_assessment.md).

- **Skip if mode is `auto` or `headless`.** The operator chose the
  model at launch.
- **In `interactive` / `guided`**: apply the heuristics in the rule
  against the Validate output. If any signal triggers, emit the
  prompt template from the rule and wait for the user to reply
  before continuing to Step 4.

This step appears in the TodoWrite checklist as Step 3. It's a brief
check — mark it completed as soon as the recommendation is emitted (or
immediately in `auto` / `headless`, where it is skipped).

---

## Step 4: Plan

See [`steps/04_plan.md`](steps/04_plan.md).

---

## Steps 5-7: Research / Architecture / Design

See [`steps/05_07_research_architecture_design.md`](steps/05_07_research_architecture_design.md).

---

## Plan Review & Q&A gate (interactive only)

See [`steps/plan_review_gate.md`](steps/plan_review_gate.md). Runs after
Design (Step 7) and before Code (Step 8); not a numbered step.

---

## Step 8: Code

See [`steps/08_code.md`](steps/08_code.md).

---

## Documentation (after Code)

See [`steps/documentation.md`](steps/documentation.md). Runs in every mode,
after Code and before Test; not a numbered step.

---

## Research Sync (after Code)

See [`steps/research_sync.md`](steps/research_sync.md). Runs in every mode,
after Code (alongside Documentation) and before Test; not a numbered step.

---

## Step 9: Test

See [`steps/09_test.md`](steps/09_test.md).

---

## Step 10: Review

See [`steps/10_review.md`](steps/10_review.md).

---

## Step 11: Commit

See [`steps/11_commit.md`](steps/11_commit.md).

---

## Step 12: Monitor Pipeline

See [`steps/12_monitor.md`](steps/12_monitor.md).

---

## Step 13: Merge

See [`steps/13_merge.md`](steps/13_merge.md).

---

## Step 14 (Bug only): Cherry-pick

See [`steps/14_bug_cherry_pick.md`](steps/14_bug_cherry_pick.md).

---

## Progress reporting

Show at start:

```
Development Pipeline: MDP-12345 (auto mode)
Steps: Jira > Validate > Model Assessment > Plan > Research > Architecture > Design > Code > Test > Review > Commit > Monitor > Merge > [Bug: Cherry-pick]
```

(Omit the Bug step from the display for non-Bug tickets.)

After completion:

```
Pipeline Complete: MDP-12345
  1. Jira:             Done — ...
  2. Validate:         Done — ...
  3. Model Assessment: Done — ...
  4. Plan:             Done — ...
  ...
  12. Monitor:         Done — pipeline green after N minutes
  13. Merge:           Done — MR merged, ticket → Testing
```

For Bug tickets, append after Merge:

```
  Bug: Cherry-pick  Done — RC MR: [url] (pipeline: green/red) | Master MR: [url] (pipeline: green/red) | Bug fields updated
```
