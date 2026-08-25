# Spike Step 5: Follow-up Tickets (conditional)

**Triggers when:**

- Interactive/guided: user approves ticket creation, OR the Spike
  description explicitly says to create tickets.
- Auto: the Spike description explicitly says to create tickets, OR the
  report identifies work that must be done (production bug found, gap
  in Feature requirements, missing functionality, etc.).
- If in auto mode and unsure whether to create, err toward creating
  and notifying the user — they can move tickets to a different
  Feature if needed.

**Skip when:** no follow-up recommendations, or user declines
(interactive/guided).

**Interactive/guided:** always confirm before creating Jira tickets.
**Auto:** always notify the user of any tickets created.

## Determining ticket type

| Work identified | Ticket type |
|---|---|
| Dev work needed (new feature, change, enhancement) | Story |
| Further research needed | Spike |
| Production bug found | Bug |
| Server maintenance needed | DevOps Request |

## Parent Feature

Use the Spike's parent Feature as the parent for all created tickets.
If the Spike has no parent Feature (orphaned Spike), create the
tickets without a parent. Always report the created ticket URLs to
the user — they may need to reassign them.

## Creating tickets

For each approved follow-up item, use `mcp__jira__create_issue`. Pass
plain text or markdown for `description` — ADF encoding is handled
internally. End every `description` with the AI co-author trailer per
`./rules/git/commit_trailer.md`.

### Story

```
mcp__jira__create_issue(
  project_key: "PS",
  issuetype: "Story",
  parent_key: "[PARENT_FEATURE_KEY]",
  summary: "Work item title",
  description: "Follow-up from Spike [SPIKE_KEY].\n\nBrief description from spike findings.\n\nSee spike report: .workspace/[SPIKE_KEY]/spike_report.md"
)
```

### Spike

```
mcp__jira__create_issue(
  project_key: "PS",
  issuetype: "Spike",
  parent_key: "[PARENT_FEATURE_KEY]",
  summary: "Research: [question]",
  description: "Follow-up research from Spike [SPIKE_KEY].\n\nResearch question and what a successful outcome looks like."
)
```

### Bug

```
mcp__jira__create_issue(
  project_key: "PS",
  issuetype: "Bug",
  parent_key: "[PARENT_FEATURE_KEY]",
  summary: "Bug title",
  description: "Production bug identified during Spike [SPIKE_KEY].\n\nDescription of the bug from spike findings.\n\nSee spike report: .workspace/[SPIKE_KEY]/spike_report.md",
  bug_fields: {
    reason_for_request: "Production bug identified during spike research.",
    how_big: "1 sentence: what is broken and impact",
    how_many_clients: "all clients / specific list",
    workaround: "YES / NO",
    risk_of_not_doing: "Risk of not fixing.",
    risk_of_doing: "Risk of fixing."
  }
)
```

Populate `bug_fields` from spike findings where possible. If a field
can't be determined from the research, use a placeholder and flag it
in your report.

### DevOps Request

```
mcp__jira__create_issue(
  project_key: "PS",
  issuetype: "DevOps Request",
  parent_key: "[PARENT_FEATURE_KEY]",
  summary: "DevOps request title",
  description: "Server maintenance identified during Spike [SPIKE_KEY].\n\nExact action needed, which servers/environments, and why."
)
```

## After creating each ticket

Link it to the Spike (`is related to`) using
`mcp__jira__create_issue_link`:

```
mcp__jira__create_issue_link(
  link_type: "Relates",
  inward_key: "[SPIKE_KEY]",
  outward_key: "[NEW_TICKET_KEY]"
)
```

Report all created ticket keys, types, titles, and URLs. Always report
these to the user regardless of mode — they may need to reassign
orphaned tickets.
