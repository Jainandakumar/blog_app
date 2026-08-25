# Spike Pipeline (Research Tickets)

Steps: Jira (done) → Plan Research → Conduct Research → Report → Follow-up Tickets → Update Jira

**Step 1 (Jira) is already complete** — handled by the calling
orchestrator before reading this file. The ticket is a Spike: no code
changes, no branch.

---

## STATE_develop.md update protocol

After every step completes, follow the full "After every step completes"
protocol in `./rules/planning/run_state.md` — update
`[workspace]/STATE_develop.md` **and push it** to the shared workspace
repo (`./rules/planning/workspace_sync.md`); the push is part of
that protocol, not a separate step. Inline orchestrator work — not a
TodoWrite item.

---

## Step 1.5: Model assessment — always recommend Opus

Spikes are research-heavy by definition. Skip the heuristic and
**always** emit the recommendation prompt at the start (per
[`../../../rules/develop/model_assessment.md`](../../../rules/develop/model_assessment.md)).

Skip in `auto` / `headless` modes (operator chose model at launch).
In `interactive` / `guided`, emit the rule's prompt template with the
reasoning load described as "spike research — deep investigation."
Wait for the user's reply before continuing to Step 2.

Not on the TodoWrite checklist — orchestrator-internal check.

---

## Step 2: Plan Research

Launch a general-purpose Agent:

```
"Read `./agents/spike_plan.md` for your instructions.

Research question: [REQUIREMENTS from Jira]
Context: [PARENT FEATURE, LINKED ITEMS from Jira]
Workspace: [workspace path]
Local overrides: [relevant items from LOCAL.md]"
```

---

## Step 3: Conduct Research

Launch subagents per sub-question in batches of up to 3 at a time.
Process ALL sub-questions from the plan — wait for each batch to
complete before launching the next.

**Codebase research:**

```
"Read `./agents/spike.md` for methodology.

Sub-question: [QUESTION]
Context: [FULL CONTEXT]
Workspace: [workspace path]
Local overrides: [relevant items from LOCAL.md]

All findings must be evidence-backed.
Write findings to [workspace]/research_[N].md (where N is the
sub-question number)."
```

**Web + code research:**

```
"Read `./agents/spike.md` for methodology.

Sub-question: [QUESTION]
Context: [FULL CONTEXT]
Workspace: [workspace path]
Local overrides: [relevant items from LOCAL.md]

Use web sources AND verify against codebase.
Rate findings per `./rules/agent_authoring/research_confidence.md`
(Confirmed / Likely / Uncertain / Unverified).
Write findings to [workspace]/research_[N].md."
```

---

## Step 4: Report

```
"Read `./agents/spike.md` for the report output format.

Workspace: [workspace path]
Ticket: [TICKET_KEY]

Read all [workspace]/research_*.md files. Compile them into a single
report at [workspace]/spike_report.md using the output format from
spike.md.

- Synthesize overlapping findings across sub-questions
- Preserve confidence levels from each research file
- Flag any contradictions between sub-question findings

Return a brief summary (3-5 lines): answer to the research question,
count of confirmed/unverified findings, and any key risks."
```

**After the agent returns:**

- **Interactive:** read and present `[workspace]/spike_report.md` for
  review. `AskUserQuestion` options:
  `Continue` / `Create follow-up tickets` / `Stop`.
  If `Create follow-up tickets`: run Step 5, then ask again.
- **Guided:** read and present for approval.
- **Auto:** proceed to Step 6 (note unverified findings in the Jira
  comment). If the report recommends follow-up work items, run Step 5
  before Step 6.

---

## Step 5: Follow-up Tickets (conditional)

See [`steps/spike_05_followup.md`](steps/spike_05_followup.md).

---

## Step 6: Update Jira

**6.1. Post summary comment** on the ticket with:

- Brief findings (2-3 sentences)
- Key recommendations
- Link to full report: `.workspace/[TICKET_KEY]/spike_report.md`
- Unverified items needing human follow-up

Interactive/guided: confirm comment content before posting. Auto: post
and report.

```
mcp__jira__add_comment(issue_key: "[TICKET_KEY]", body: "[summary in markdown; end with the AI co-author trailer per ./rules/git/commit_trailer.md]")
```

**6.2. Advance ticket status** per
`./rules/jira/status_rules.md` (Spikes complete to **Done**):

```
mcp__jira__transition_issue(issue_key: "[TICKET_KEY]", to_status: "Done")
```

If the tool returns a transition error, warn but don't block — the
research is complete regardless.

---

## Progress

```
Spike Complete: MDP-12345
  1. Jira:             Done — research question understood
  2. Plan:             Done — N sub-questions identified
  3. Research:         Done — N confirmed, N unverified
  4. Report:           Done — .workspace/MDP-12345/spike_report.md
  5. Follow-up:        Done — N stories created (or Skipped)
  6. Update Jira:      Done — summary comment posted, status → Done
```
