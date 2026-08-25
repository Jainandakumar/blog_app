---
name: github
description: Check MR status, read pipeline results, and view code review comments.
disable-model-invocation: true
argument-hint: "[check|comments] [MR-IID]"
---

# GitHub MR Operations

Read MR details, pipeline status, and code review comments for the current branch.

**Usage:** `/github [subcommand] [MR-IID]`

## Arguments

- `$0` — Subcommand: `check` (default), `comments`
- `$1` — MR IID (optional — auto-detect from current branch if omitted)

Parse the arguments from: `$ARGUMENTS`

If no arguments provided, default to `check` with auto-detection.

**Mode.** Detect per `../../rules/develop/pipeline_modes.md`
(`_CODE_ENTRYPOINT=sdk-cli` → `headless`; otherwise `interactive`).
This skill is read-only; mode mainly affects whether `AskUserQuestion`
gates fire. Persist mode to `STATE_github.md` when an MR-IID is
established.

---

## Setup Check

Before doing real work, ensure `/setup verify` has succeeded for this session.
If it hasn't, run `/setup` first.

The remaining check below is github-specific defense-in-depth:

```
mcp__github__check_auth()
```

If it returns `{error: "..."}`: tell the user **"GitHub not configured. Run `/setup github` to set it up."** and stop.

---

## Subcommand: `check` (default)

Show a concise MR overview with pipeline status.

### Step 1: Find the MR

If MR IID provided as `$1`, use it directly.

Otherwise, auto-detect from current branch:
```
mcp__github__find_mr()
```

If result is `null`, report:
"No open MR found for the current branch. Push and create an MR first."

### Step 2: Fetch MR details

Always use `get_mr` for full details — `find_mr` does not reliably include pipeline data:
```
mcp__github__get_mr(mr_iid: N)
```

Extract: `iid`, `title`, `state`, `web_url`, `merge_status`, `head_pipeline.status`,
`head_pipeline.id`, `head_pipeline.web_url`.

### Step 3: Count unresolved discussions

```
mcp__github__get_discussions(mr_iid: N)
```

Count discussions where any note has `resolvable: true` AND `resolved: false`.
Skip notes where `system: true`.
Categorize by author source (see Comment Source Identification below).

### Step 4: Fetch pipeline jobs

```
mcp__github__get_pipeline_jobs(pipeline_id: N)
```

### Step 5: Display summary

```
MR !{iid}: {title}
URL: {web_url}
Status: {state} | Target: {target_branch} | Merge: {merge_status}
Pipeline: {pipeline_status} (ID: {pipeline_id})
Unresolved threads: {count} ({breakdown by source})

Pipeline jobs:
  ✓ build         passed
  ✓ preflight     passed
  ✗ pronto-bot    failed
  ◷ spec-models   running
  ...
```

If pipeline has failed jobs, list them with their stage and status.

---

## Subcommand: `comments`

Show detailed code review comments, grouped by source.

### Step 1: Find MR (same as check)

### Step 2: Fetch all discussions

```
mcp__github__get_discussions(mr_iid: N)
```

### Step 3: Categorize and filter

Categorize each discussion by its first note's `author.username` using the
Comment Source Identification table below. Skip notes where `system: true`.

Filter: show only unresolved discussions by default.
If all discussions are resolved, say "All discussions resolved" and show count.

### Step 4: Display grouped

```
## Unresolved Discussions ({count})

### CI: Static Analysis ({count})
1. [E] app/models/user.rb:42 — Brakeman: SQL injection risk in query
2. [F] app/controllers/api_controller.rb:15 — RuboCop: Missing frozen_string_literal

### CI: Code Review ({count})
1. [W] app/models/enrollment.rb:88 — Functional: Hardcoded string instead of constant
2. [I] app/views//show.html.erb:12 — Style: Consider extracting to partial

### Human Reviewers ({count})
1. @jsmith on app/models/user.rb:42 — "Can we add a test for the nil case?"
2. @jsmith (general) — "LGTM overall, just the one question above"
```

For each discussion, show:
- Severity (if from CI: E/F/W/I)
- File and line (if inline/diff comment)
- The comment body (first 100 chars, or full if short)

---

## Comment Source Identification

| Author username | Source | Body pattern | What it means |
|----------------|--------|-------------|--------------|
| `project_14_bot_0b199470baf7fca5fa76d6668c86efbd` | Static Analysis (Pronto Bot) | Contains `[Static Analysis]` | E/F severity lint errors |
| `` |  Code Review ( Reviewer) | Starts with severity emoji (`🚨`, `⚠️`) | W/I severity + semantic review |
| Any other non-system username | Human reviewer | — | Manual code review comment |

Match by `author.username` first. If a new bot is added, fall back to body pattern matching.

---

## Error Handling

- **No MR found:** "No open MR for the current branch. Create one first."
- **Pipeline not started:** "Pipeline hasn't started yet. It may take a minute after push."
- **Auth error:** "Run `/setup github` to re-configure GitHub access."
- **API rate limit:** "GitHub rate limit hit. Wait a moment and try again."

---

## Important Notes

- **Pagination:** `get_discussions` handles pagination internally — no manual paging needed.
- **Never expose tokens** in output or error messages.
- This skill is read-only — it does not modify code or create commits.
