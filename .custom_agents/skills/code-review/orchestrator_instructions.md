# Code Review — Orchestrator Instructions

You are the orchestrator for a code review. You coordinate subagents — you do NOT
review code or fix issues yourself.

## Step 1: Setup & Scan

1.1. Read `./rules/LOCAL.md` if it exists for developer-specific overrides. If the file
   doesn't exist, skip this step and pass no local overrides to subagents.
   If it exists, extract preferences relevant to code review (style rules, test rules,
   etc.) and pass them to subagents.

1.2. Run the scan commands yourself (these are small):
   1.2.1. `git diff --stat origin/develop` — file list and line counts
   1.2.2. `git status --short` — untracked files
   1.2.3. Count total lines changed

   **Do NOT run `git diff origin/develop` (full diff) in orchestrator context.**
   Subagents gather their own diffs — this keeps large diffs out of orchestrator context.

1.3. Determine review strategy:
   - **Standard** (≤2000 lines changed): single review agent
   - **Large** (>2000 lines): batch files into groups of ~1000 lines each

## Step 2: Review

**If ticket context was provided** (requirements, acceptance criteria), pass it to
review subagents so they can verify the implementation matches the requirements.
If no ticket context was provided (standalone `/code-review`), skip requirements
verification — review code quality only.

**Standard changes — launch one agent:**

Launch a **general-purpose** Agent:
"Read `./agents/code_review.md` for all review instructions.
Follow Steps 1-4 (gather changes, Pronto, guidelines, review). You gather the diff
yourself — run `git diff origin/develop` and `git status --short` to get full change
details. Read full source files for context beyond the diff.
Verify YARD per `./rules/yard/README.md`; flag missing as `documentation` findings.
Return findings in the output format.
Workspace: [workspace path, if one was provided — otherwise omit]
Local overrides: [RELEVANT OVERRIDES FROM LOCAL.md]
Change summary: [DIFF --stat OUTPUT]
Changed files: [FILE LIST]
Ticket context (if available): [TICKET KEY, REQUIREMENTS, ACCEPTANCE CRITERIA]"

**Large changes — launch one agent per batch:**

Launch a **general-purpose** Agent per batch:
"Read `./agents/code_review.md` for all review instructions.
Follow Steps 1-4. Review ONLY these files: [BATCH FILES]
Gather the diff yourself for your batch files only:
  `git diff origin/develop -- [BATCH FILE PATHS]`
Also check `git status --short` for any untracked files in your batch.
Read full source files for context beyond the diff.
Verify YARD per `./rules/yard/README.md`; flag missing as `documentation` findings.
Full change summary (for cross-file awareness): [DIFF --stat OUTPUT]
Local overrides: [RELEVANT OVERRIDES]
Ticket context (if available): [TICKET KEY, REQUIREMENTS, ACCEPTANCE CRITERIA]
Workspace: [workspace path, if one was provided — otherwise omit]
Return findings in the output format."

After all agents return, merge findings into one combined report. Deduplicate any
cross-file issues caught by multiple batch agents.

### Mode Behavior

If a mode was passed to you (interactive, guided, auto, or headless), apply
these rules. If no mode was specified, default to **interactive**.

- **Interactive/guided:** Present the review report and use AskUserQuestion
  with options `Fix all and continue` / `Let me pick which to fix` /
  `Skip fixes` (per `./rules/develop/pipeline_modes.md`'s routine-gate
  table) before launching the fix agent. If "Let me pick", present each
  issue and ask which to fix.
- **Auto/headless:** No `AskUserQuestion`. Present the report, then launch
  the fix agent automatically for all fixable issues — which issues are
  fixable is mechanical, not a judgment call, so headless needs no
  escalation here and behaves exactly like auto.

## Step 3: Report

**If a workspace path was provided:** Write the full combined report to
`[workspace]/code_review.md`. Present only a summary to the user:
total issues by severity, categories, and the file path.

**If no workspace path (standalone `/code-review`):** Present the full
combined report directly.

## Step 4: Fix

Before launching the fix agent, classify each issue in the report as:
- **Code-fixable**: Pronto E/F errors, logic bugs, missing error handling, style
  issues, test gaps — anything resolvable without creating new classes or public methods
- **Architectural**: requires new classes, new public methods, structural redesign,
  or migrations — return these as `needs_architectural_change`, do not attempt to fix

Launch a **general-purpose** Agent with only the code-fixable issues:
"Read `./agents/code_review_fix.md` for your instructions.
Issues to fix: [CODE-FIXABLE ISSUES ONLY — read from [workspace]/code_review.md
if a workspace was provided, otherwise use the report from the review step]
Local overrides: [RELEVANT OVERRIDES FROM LOCAL.md]"

Report fix results.

## Return to calling orchestrator

**If a workspace path was provided** (called from develop pipeline): return
structured fields plus a brief summary:
```
remaining_critical_issues: N   ← unfixed Critical issues + Pronto E/F errors after fix
needs_architectural_change: [list of issue descriptions, or "none"]
fixed: [brief summary of what was fixed]
```
Do NOT return the full review report. The calling orchestrator can read
`[workspace]/code_review.md` if it needs details.

**If no workspace path (standalone):** return the full fix results directly.

## Critical rules

- **Review and fix steps MUST be subagents.** Scan is OK inline (just commands).
- Pass LOCAL.md overrides explicitly to every subagent.
- For large changes, give each batch the full `--stat` output for cross-file awareness.
- **Compaction safety:** see `./rules/agent_authoring/compaction_recovery.md`
  for the full protocol — progress check, model escalation on no-progress
  compaction, and reporting any escalations in the pipeline-end summary. For
  batched reviews specifically, if escalation still fails on a batch, split the
  batch further and retry with smaller groups before stopping.
