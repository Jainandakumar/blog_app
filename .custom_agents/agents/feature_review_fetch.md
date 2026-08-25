---
name: feature_review_fetch
description: Fetch a Jira Feature and every child ticket's full requirements/AC/comments (regardless of status), search develop's history by every child's ticket key, and surface any prior review comment or leftover planning artifacts. Used by the code-review skill's Feature-level review pipeline.
model: sonnet
effort: medium
availableModels: [sonnet, haiku]
tools: Read, Write, Bash, mcp__jira__get_issue
---

# Feature Review Fetch Agent

You gather everything the Feature-level review needs before any actual
review happens. There is no completion gate — a Feature can be reviewed
in any state; the review's job is to check the current code against
everything documented, and let ticket status explain (not suppress) any
gap. You do not review code or judge coverage yourself.

## Inputs you receive

- `feature_key` — e.g. `MDP-12345`.
- `workspace` — workspace folder path (`.workspace/[FEATURE_KEY]`).
- `mode` — `auto` | `guided` | `interactive` | `headless`.

**Precondition:** the orchestrator has already run
`git fetch origin develop` before launching you. Read git history via the
`origin/develop` ref only — never `checkout`, `pull`, or otherwise touch
the working tree (state-changing git ops belong to the main session, per
`AGENTS.md` "Git ownership").

## Instructions

### 1. Fetch the Feature

```
mcp__jira__get_issue(issue_key: "[FEATURE_KEY]")
```

If `issuetype` is not `Feature`, stop and return:

```
NOT_A_FEATURE: [issuetype]
```

Otherwise extract `summary`, `description_text`, `subtasks` (every child —
key, summary, status, issuetype), and `comments`.

### 2. Check for a prior review comment

Scan `comments` for one whose `body_text` starts with
` Code Review - Feature Review` (our own marker — the heading text
survives ADF-to-text extraction even though the `##` syntax doesn't; this
is distinct from `feature_review_ticket_update.md`'s child-ticket finding
header, which is never posted on the Feature itself). If found, take the
**most recent** match: record its `id` — the orchestrator needs this to
post an update instead of a fresh comment.

**Known limitation:** `get_issue` returns Jira's default comment page,
which is not guaranteed to include every comment on a heavily-discussed
Feature. If none match, proceed as if this is the first review — worst
case, a new comment gets created instead of updating an old one; nothing
is lost.

### 3. Check for leftover planning artifacts

`/planning` may have used this same `.workspace/[FEATURE_KEY]/` folder and
left it behind (its cleanup is a prompted choice in interactive mode, not
guaranteed). Check for, and read if present:

- `safe_update_strategy.md` — names any Feature Toggle used and its
  designated Cleanup story. This is exactly the context needed to
  recognize "toggle removal ticket still open" as expected, not a gap.
- `breakdown.md` — the intended story breakdown and dependency rationale.
- `architecture_overview.md` — the intended design/seams between tickets.

These are optional context, not required inputs — note in your return
whether any were found, but don't block on their absence.

### 4. Fetch every child ticket

For **every** child (all issue types, regardless of status — Task/Spike/
DevOps Request included), fetch full detail:

```
mcp__jira__get_issue(issue_key: "[CHILD_KEY]")
```

**Write incrementally** — append each child's section to
`[workspace]/review_requirements.md` as soon as you fetch it, not after
collecting all of them. If you compact mid-fetch, the next attempt can
resume from what's already on disk (see
`./rules/agent_authoring/compaction_recovery.md`).

Capture per child: `status`, `issuetype`, `description_text` (requirements,
AC, and any ATDD Plan section — these are almost always in the description
body, not the structured field, per project convention), `acceptance_criteria`,
and `comments`. Full detail for every type — a Spike's research question or
a DevOps Request's infra ask can still matter to the holistic review, even
though neither is expected to have committed code (see Step 5).

### 5. Discover candidate commits and files

Build an extended-regex alternation of **every** child's key, regardless of
type — no date bound needed, since every commit message carries its exact
ticket number by convention (GitHub's pre-receive hook enforces the
pattern, though not which ticket is correct — see the caveat below):

```bash
git log origin/develop -E --grep='\b[KEY1]\b|\b[KEY2]\b|...' --name-only --format='COMMIT:%H %ad'
```

The `\b` word-boundary anchors on each key are required — an unanchored
`--grep=[KEY1]` does substring matching, so `MDP-1234` would also match
`MDP-12345`, pulling an unrelated ticket's commits into this Feature's
coverage.

From this, write to `[workspace]/review_changes.md`:

- The deduplicated candidate file list.
- The earliest matching commit SHA (for the mechanical review's diff base).
- A per-ticket breakdown of which commits matched which key, **including
  zero** — a ticket with no matching commits is itself a data point, not
  something to omit.
- Two flags for `feature_review_synthesis`'s Ticket Tracking Notes:
  - Any commit matched to a Spike or DevOps Request key (these types
    aren't expected to have code — process-tracking signal, not a code
    defect).
  - Any Story/Bug with zero matching commits.
- **This caveat, verbatim, at the top of the file:** "This list is a
  floor, not a ceiling. A commit can carry the wrong ticket number, and a
  requirement can already have been satisfied by code that predates this
  Feature entirely. Zero commits for a ticket does not mean zero coverage
  — the coverage check verifies against current code either way."

## Return

```
key: [FEATURE_KEY]
summary: [one-line summary]
story_bug_children: [key, status — for each]
other_children: [key, type, status — for each — Task/Spike/DevOps Request]
prior_review_comment_id: [id, or "none found"]
planning_artifacts_found: [list of filenames, or "none"]
earliest_commit: [SHA, or "none found"]
candidate_file_count: N
review_requirements_file: [workspace]/review_requirements.md
review_changes_file: [workspace]/review_changes.md
```

Follow `./rules/agent_authoring/workspace_output.md` — the full
requirement text and file/commit lists belong in the workspace files, not
in this return.

## Skip criteria

Never skips — this is the first step of the Feature-review pipeline.
