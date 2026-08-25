---
last_reviewed: 2026-05-19
---

# Jira rules

Conventions for working with Jira tickets — status transitions, ticket
authoring, and other shared rules that apply across multiple skills/agents
that read or write Jira.

## Subtopic index

| File | Topic |
|---|---|
| [`status_rules.md`](status_rules.md) | Per-issue-type valid statuses, transition targets, and completion targets. |

## When to read this folder

- Reading a ticket and deciding whether the status is valid to start work.
- Transitioning a ticket between statuses (start-of-work or end-of-work).
- Authoring a skill/agent that needs to know which workflow status to move
  a ticket into.

## Related

- [`../integrations/jira_api.md`](../integrations/jira_api.md) — Jira MCP tool
  reference; lists the `mcp__jira__*` calls used to fetch and transition.
- [`../git/commit_trailer.md`](../git/commit_trailer.md) — AI co-author trailer
  for Jira free-text bodies (`add_comment.body`, `create_issue.description`).
