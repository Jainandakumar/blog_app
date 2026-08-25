# Feature Planning Instructions

Break a Jira Feature into fully-specced User Stories that are small enough (1-2 SP)
and detailed enough for `/develop` to execute autonomously with zero questions.

## State and Modes

See `./rules/planning/run_state.md` (`CONTEXT.md` / `STATE_planning.md`
format) and `./rules/develop/pipeline_modes.md` (modes). On resume,
apply the trust/verify check to `completed_steps`, pick up at first
surviving `pending_steps`. Create `STATE_planning.md` after Step 1 fetch;
update after every step and decision, following run_state.md's full
protocol — each update is followed by a push to the shared workspace repo
(`./rules/planning/workspace_sync.md`).

| Mode | Pauses |
|---|---|
| Interactive | Steps 1 (right-ticket gate), 4 (strategy), 5 (breakdown), 8 (pre-Jira) |
| Guided | Step 8 only (all briefs) |
| Auto / Headless | Step 8 only — these are real Jira tickets |

---

## Step 1: Fetch the Feature

Launch a **general-purpose** Agent with `./agents/jira_context_fetch.md`,
passing `Ticket: [FEATURE_KEY]`, `Workspace: [workspace path]`, `Mode: [MODE]`,
`Output filename: feature_context.md`.

### Attachments processing (orchestrator-level, after Step 1 returns)

If `attachments_to_process` is non-empty, launch a **general-purpose** Agent
with `./agents/planning_attachments.md`, passing the attachment list,
`Feature: [FEATURE_KEY]`, and `Workspace: [workspace path]`. Instruct it to
write descriptions to `[workspace]/attachments.md`.

After it returns, append the descriptions into `feature_context.md` so
downstream subagents see them without an extra read.

**Right-ticket gate.** If `type` includes a warning (not a Feature), present
the warning and ask if the user wants to proceed anyway.

**In interactive mode:** Display a summary from the return values (key,
summary, type, status, priority, children count, parent initiative,
attachments, `feature_context.md` path), then `AskUserQuestion` with
`Proceed with breakdown` / `Stop`.

Initialize `[workspace]/STATE_planning.md` after a successful fetch and
before the right-ticket gate. On a resume, `STATE_planning.md` already
exists — update `last_updated_at` and skip re-fetching.

**Review the Initiative (always relevant).** The parent Initiative captured in
`feature_context.md` is the authoritative description of the overall
application functionality this Feature belongs to. Treat it as required
context: it flows to Research (Step 2), Breakdown (Step 5), and Briefs (Step 7)
via `feature_context.md`, and it should be surfaced in the interactive
right-ticket summary so the user confirms the Feature sits under the expected
Initiative. This is review-for-context only — `/planning` does not modify the
Initiative.

---

## Step 1.5: Model assessment

After Feature fetch, before Research: apply
[`../../rules/develop/model_assessment.md`](../../rules/develop/model_assessment.md)
against the Feature description (scope, scale, ambiguity). Skip in
`auto` / `headless`. Not tracked in TodoWrite.

---

## Step 2: Research the codebase

Launch a **general-purpose** Agent with `./agents/planning_research.md`,
passing `Feature: [SUMMARY]`, the `feature_context.md` and `attachments.md`
paths, `Workspace: [workspace path]`, and `Local overrides:` from `LOCAL.md`.
The agent writes findings to `[workspace]/codebase_research.md`.

---

## Step 3: External Research

**Skip when:** The Feature is purely internal (no external libraries, version
upgrades, or third-party integrations). Return
`SKIP: No external research needed.`

**Runs when:** Library upgrades, gem changes, framework migrations,
third-party API integrations, or any work the local codebase alone cannot
answer "what needs to change and how?" for.

Launch a **general-purpose** Agent with
`./agents/planning_external_research.md`, passing `Feature: [SUMMARY]`,
the `feature_context.md` path, the key findings from Step 2,
`Workspace: [workspace path]`, and `Local overrides:` from `LOCAL.md`. The
agent writes findings to `[workspace]/external_research.md`.

---

## Step 4: Select Safe Update Strategy

**Always runs when the Feature modifies existing code used in multiple
places.** Skip only for purely additive Features (new endpoints, new models
with no existing callers).

See `./rules/planning/safe_update_strategy.md` for the strategy types,
selection rules, Feature Toggle naming, and the required Setup / Cutover /
Cleanup stories.

Write the selected strategy to `[workspace]/safe_update_strategy.md` (format
in the shared rule). The breakdown and brief agents read this file directly.

**In interactive mode:** Present the strategy recommendation and confirm
before proceeding to the breakdown step.
`AskUserQuestion` options: `Proceed` / `Change strategy` / `Stop`.

---

## Step 5: Create high-level story breakdown

Launch a **general-purpose** Agent with `./agents/planning_breakdown.md`,
passing `Feature: [SUMMARY]`, the workspace paths for `feature_context.md`,
`codebase_research.md`, `external_research.md` (if exists),
`safe_update_strategy.md` (if exists), `attachments.md` (if exists),
`Workspace: [workspace path]`, and `Local overrides:` from `LOCAL.md`. The
agent writes the breakdown to `[workspace]/breakdown.md`.

**In interactive mode:** Present the high-level breakdown and ask for approval
before proceeding to detailed specs.

---

## Step 6: Architecture overview on Feature ticket

After Step 5 is approved (or immediately in auto/guided mode), launch a
**general-purpose** Agent with `./agents/planning_architecture_overview.md`,
passing the feature key and workspace path.

---

## Step 7: Create detailed briefs for each ticket

Read `[workspace]/breakdown.md` to get per-ticket details and dependency
order. Every ticket needs a brief file at `[workspace]/story_[N]_brief.md` —
the Step 8 creation agent reads it. See sibling `brief_dispatch.md` for
per-type prompts, parallelization, and dependency ordering.

---

## Step 8: Present and create tickets in Jira

Present the summary table returned by the breakdown agent (Step 5) — do not
re-read `breakdown.md`. Add a `## Feature Breakdown: [FEATURE_KEY]` header
with the Feature summary and the agent's table/totals, plus a `Key` column
(initially `—`).

Then ask: **"Create these N tickets in Jira under [FEATURE_KEY]?"** Even in
auto mode, confirm before creating — these are real Jira tickets.

**Create each ticket** by launching a **general-purpose** Agent per ticket
(up to 3 in parallel) with `./agents/planning_jira_create.md`, passing
the brief path, feature key, ticket type, and story points. This keeps large
ADF JSON construction out of orchestrator context. The agent returns: ticket
key, type, title, SP, status, notes. Capture the ticket key after each
creation.

### Link dependencies in Jira

After all stories are created, add `Blocks` links for each dependency
identified in the breakdown using
`mcp__jira__create_issue_link(link_type: "Blocks", inward_key: "MDP-BLOCKER", outward_key: "MDP-BLOCKED")`.
Only one direction is needed — Jira auto-populates the inverse.

### Final output

Print a `## Tickets Created` table with columns `# | Key | Type | Title | SP
| Parallel Group | Status`. SP is `—` for Spikes and DevOps Requests. Below
the table, list the dependencies linked and tell the user to start with
`/develop [first-key]`. Note that DevOps Request tickets are worked by the
DevOps team, not via `/develop`. Then clean up the workspace per
`../../rules/develop/pipeline_modes.md`: Interactive/Guided ask via
`AskUserQuestion`; Auto/Headless run `rm -rf .workspace/[FEATURE_KEY]/`.

---

## Error Handling

- **Feature not found (404):** Ask the user to verify the ticket key.
- **Not a Feature:** Warn and ask — the skill is designed for Features but
  could work with any parent issue type.
- **Story creation fails (non-429):** Report, continue with remaining
  stories, summarize failures at the end.
- **Rate limiting (429):** Wait 1 second and retry until success or non-429.
- **Token issues (401):** Guide the user to verify their API token.
- **Existing children:** Note them, don't create duplicates. Flag overlap
  with existing stories and ask.
- **Link creation fails:** Report but don't block — links can be added
  manually.

---

## Important Notes

- **Story point estimates are suggestions.** Interactive mode lets the user adjust before Jira creation.
- **Specs reference the current codebase state.** Note risk if the Feature depends on other Features that change the codebase.
- **Story ordering matters.** Number in implementation order; note dependencies. `/develop` runs them in order (respecting parallel groups).

---

## Compaction Recovery

See `./rules/agent_authoring/compaction_recovery.md` for the
orchestrator protocol when subagents return errors or truncated responses.
