# `/research` — Answer pipeline

A repeatable procedure, not a numbered pipeline that terminates — see
`./rules/research/session_continuity.md`. Run this once per question,
including the first one after bootstrap and every later plain-chat follow-up
in the same conversation.

## Per-question flow

1. **Consult `topic_index.md`** for candidate rows relevant to the question
   — grep the Docs/Code/YARD tables and `Open questions / gaps` by keyword
   and by any `aliases` in the frontmatter.
2. **Launch `research_answer.md`:**
   ```
   "Read `./agents/research_answer.md` for your instructions.

   question: [the question text]
   candidate_rows: [rows found in step 1]
   workspace: [workspace path]
   ticket_key: [TICKET_KEY, or empty in topic-mode]"
   ```
   It re-verifies against current files, rates confidence, appends the turn
   to `qa_log.md`, and updates `Last Verified`/confidence on the rows it
   touched — all inside its own run (see `research_answer.md`'s Output).
3. **Push** (ticket-mode only) per `workspace_sync.md`, now that
   `topic_index.md` and `qa_log.md` have changed.
4. **Present the answer** and stay open for the next question — no closing
   statement that implies the session is done.

## Finding-triage, inline (v1 scope — full workflow, not deferred)

If `research_answer.md`'s return includes `doc_defects` or `bug_findings`,
handle them now, per `./rules/research/findings.md` — don't defer to
"the end" (there is no end):

- **`doc_defects`** — append each to `[workspace]/doc_review.md` using
  `feature_docs.md`'s checklist format (`findings.md` explains the `{type}`
  mapping). Skip an identical open item.
- **`bug_findings`** — append each to `[workspace]/findings.md`.
  - **Ticket-mode:** log only.
  - **Topic-mode:** `AskUserQuestion` — "Create a ticket for this finding?"
    (`Create ticket` / `Skip`). On `Create ticket`, ask which Feature to
    parent it under, then launch `./agents/planning_jira_create.md`
    with a brief built from the finding; update the `findings.md` entry's
    `Status` to `ticket created ({TICKET_KEY})`.
  - Repeat this ask for every new, distinct finding as it surfaces.

## Spike-depth escalation

If a question is broad or multi-faceted enough that `research_answer.md`
returns `NEEDS_DECISION` recommending it (see its NEEDS_DECISION examples),
escalate instead of retrying it as a direct lookup. `N` is the next unused
index — glob `spike_report_*.md` in the workspace and take the highest
existing index + 1 (starting at 1).

1. **Decompose**, unmodified:
   ```
   "Read `./agents/spike_plan.md` for your instructions.

   research_question: [the question text]
   context: [topic/ticket summary]
   workspace: [workspace path]
   local_overrides: [relevant items from LOCAL.md]"
   ```
   `spike_plan.md` writes its sub-question breakdown to the fixed
   `[workspace]/plan.md` — read it immediately and use its sub-questions;
   it's a transient intermediate for this escalation only; a later
   escalation overwriting it is fine since nothing else references it.
2. **Fan out**, unmodified, one launch per sub-question, each to its own
   `research_{N}_{sub}.md`:
   ```
   "Read `./agents/spike.md` for your instructions.

   Research question: [sub-question]
   Workspace: [workspace path]
   Output file: [workspace]/research_{N}_{sub}.md"
   ```
3. **Compile**, via `spike.md` again, into `spike_report_{N}.md`:
   ```
   "Read `./agents/spike.md` for your instructions.

   Compile the findings in [workspace]/research_{N}_*.md into one report
   answering: [the original question text]
   Workspace: [workspace path]
   Output file: [workspace]/spike_report_{N}.md"
   ```
4. Present `spike_report_{N}.md`'s summary as the answer to the original
   question, then continue the per-question flow above (finding-triage
   still applies to anything the spike surfaced).
