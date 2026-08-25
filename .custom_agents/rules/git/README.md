---
last_reviewed: 2026-05-19
---

# Git rules

Conventions for Git interactions — commit message shape, trailers, branch
naming, and the AI co-author convention that applies to commits and to free-text
Jira fields the AI authored.

## Subtopic index

| File | Topic |
|---|---|
| [`branch_naming.md`](branch_naming.md) | Feature-branch name format, lifecycle, and Spike exception. |
| [`commit_trailer.md`](commit_trailer.md) | AI co-author trailer for commits and Jira free-text bodies. |

## When to read this folder

- Authoring a commit message.
- Creating a feature branch (name format, charset, length cap).
- Authoring or shaping a Jira `add_comment.body` or `create_issue.description`.
- Reviewing a skill/agent that posts free-text content to Jira and needs to
  confirm the trailer rule.

## Related

- [`../integrations/jira_api.md`](../integrations/jira_api.md) — Jira MCP tool
  reference; points back here for the trailer rule.
- `LOCAL.md` — per-developer overrides may apply.
