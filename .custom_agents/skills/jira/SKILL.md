---
name: jira
description: Read a Jira ticket, check/transition status, create a branch, and start development.
disable-model-invocation: true
argument-hint: <ticket-key> [auto|guided|interactive|headless]
---

# Jira Ticket Workflow

Read a Jira ticket, check/transition its status, create a branch, parse requirements,
and begin development.

**Usage:** `/jira MDP-12345 [mode]`

**Modes:** `interactive` (default), `guided`, `auto`, `headless`. See
`../../rules/develop/pipeline_modes.md` for canonical semantics.
`_CODE_ENTRYPOINT=sdk-cli` auto-elevates to `headless`. Persist
mode to `STATE_jira.md`.

## Arguments

- `$0` — Jira ticket key (e.g., `MDP-12345`). Required.
- `$1` — Interactivity mode: `auto`, `guided`, or `interactive`. Default: `interactive`.

**Ticket key normalization:**
- Bare number (e.g., `12345`) → add prefix: `MDP-12345`
- Already prefixed (`MDP-12345`) → use as-is
- Empty → ask the user for one

**This skill requires a Jira ticket (MDP- prefix).** If the user provides a `LOCAL-`
key or says there is no ticket, stop: "This skill reads Jira tickets — LOCAL tickets
are not in Jira."

---

## Setup Check

Before doing real work, ensure `/setup verify` has succeeded for this session.
If it hasn't, run `/setup` first.

The remaining check below is jira-specific defense-in-depth — launch a
**general-purpose** Agent:
"Read `./agents/setup_check.md` for your instructions. Component: jira"
- If returns `OK` or `OK (fixed)`: continue.
- If returns `SKIPPED` or `FAILED`: stop and report.

---

## Execution Steps

### Step 1: Fetch ticket

Use `mcp__jira__get_issue` to fetch the ticket:
```
mcp__jira__get_issue(issue_key: "[TICKET_KEY]")
```

The response includes: `key`, `summary`, `status`, `issuetype`, `priority`,
`description_text` (already parsed from ADF), `acceptance_criteria` (with
`local_id` per item), `comments`, `attachments`, `subtasks`, `issuelinks`.

Display:
- **Key & Summary**: ticket title
- **Status**: current workflow status
- **Type & Priority**: issue type and priority level
- **Description**: `description_text` from the response
- **Acceptance Criteria**: `acceptance_criteria` items if present
- **Subtasks**: list of child tickets if any
- **Recent Comments**: last 3-5 from `comments`

**In interactive mode:** Display the ticket info and ask "Proceed?"
**In guided mode:** Continue collecting info, present everything at the end of Step 5.
**In auto mode:** Continue without pausing.

### Step 2: Check status and transition

Per-issue-type status rules — valid start statuses, start-of-work targets,
completion targets, and transition-error handling — live in
[`./rules/jira/status_rules.md`](../../rules/jira/status_rules.md). Read
that rule, then apply it to this ticket using the `status` and `issuetype`
fields from Step 1.

Only check or change the status of THIS ticket — never check or change parent
ticket status.

#### Mode behavior

**In interactive mode:** Show the planned transition and confirm before executing.
If the ticket is in an unexpected status, explain the situation and ask to continue.
**In guided mode:** Include status info in the plan summary. Ask if status is unexpected.
**In auto mode:** Attempt transition if valid. If status is unexpected or transition
fails, stop and report to user (do not silently continue).

### Step 3: Create branch

Branch-name format, charset/length cap, Spike exception, and the merge-time
lifecycle (auto-delete after merge) all live in
[`./rules/git/branch_naming.md`](../../rules/git/branch_naming.md). Read
that rule, generate the branch name from the ticket key + summary, then create
the branch from the current HEAD:

```bash
git checkout -b MDP-NNNNNN_description
```

**In interactive mode:** Show proposed branch name and confirm.
**In guided mode:** Include in the plan summary.
**In auto mode:** Create without asking.

### Step 4: Parse requirements and plan development

Extract actionable requirements from the ticket:

1. Parse the description for specific changes needed
2. Check acceptance criteria for success conditions
3. Review subtasks for breakdown of work
4. Check recent comments for additional context or clarifications

Present requirements as a structured list:
- What needs to change
- Which files/areas are likely affected (search the codebase)
- Acceptance criteria to verify against
- Any constraints or notes from comments

**In interactive mode:** Present requirements and ask "Ready to start development?"
**In guided mode:** This is where the full plan is presented — show everything from
Steps 2-5 and ask "Execute this plan?"
**In auto mode:** Proceed to development.

### Step 5: Ready for development

Report that the ticket is ready for development:
- Ticket read and requirements parsed
- Status transitioned (if applicable)
- Branch created

Suggest: "Run `/develop [ticket-key]` to start the development pipeline."

Do NOT begin development work directly — that is handled by the `/develop` pipeline,
which coordinates subagents safely without risking context exhaustion.

---

## Interactivity Mode Details

### Interactive (default)

```
Step 1: [Display ticket info]
         → "Proceed with this ticket?"

Step 2: [Check status, show planned transition or warning]
         → "Move to Development?" / "Ticket is in Planning, not Ready for Development. Continue anyway?"

Step 3: [Show branch name]
         → "Create branch MDP-233100_add_validation?"

Step 4: [Show requirements]
         → "Ready to start development?"

Step 5: [Report summary, suggest `/develop`]
```

### Guided

```
Steps 1-4: [Gather all info silently]

Present: "Here's the plan:
  - Ticket: MDP-233100 - Add field validation
  - Status: Ready for Development → Development
  - Branch: MDP-233100_add_validation
  - Requirements: [list]"

         → "Execute this plan?"

Step 5: [Report summary, suggest `/develop`]
```

### Auto

```
Steps 1-4: [Execute everything]
Report: "✓ Ticket read, ✓ Status: Development, ✓ Branch created"
Step 5: [Report summary, suggest `/develop`]
```

---

## Error Handling

- **Auth error** (`{error: "Auth failed"}`): Report and stop. Run `/setup jira` to reconfigure.
- **Issue not found**: Ticket key doesn't exist. Ask user to verify.
- **Transition error**: Report what fields are missing or blocking the transition. Provide a direct link to the ticket so the user can fix it manually.
- **Branch already exists**: Ask if user wants to check it out or create a new name.
- **Network error**: Report and retry once. If still failing, stop.
