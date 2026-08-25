---
last_reviewed: 2026-05-19
---

# Integrations

Reference docs for third-party services and MCP-tool integrations that
skills and agents call into. Each file enumerates the available tools and
the patterns expected when calling them.

## Subtopic index

| File | Topic |
|---|---|
| [`github.md`](github.md) | GitHub MCP tools (`mcp__github__*`) — list of tools, comment-source identification, version notes. |
| [`github_pipeline_polling.md`](github_pipeline_polling.md) | MR pipeline polling protocol used by skills that wait for a pipeline to reach a terminal state. |
| [`jira_api.md`](jira_api.md) | Jira MCP tools (`mcp__jira__*`) — list of tools and the AI co-author trailer convention for authored bodies. |
| [`jira_comment_limits.md`](jira_comment_limits.md) | Jira's 32,767-char ADF size cap, measured markdown→ADF overhead ratios, and the multi-comment splitting pattern for long reports. |

## When to read this folder

- Authoring a skill or agent that calls GitHub/Jira MCP tools.
- Reviewing how comments are identified (CI bot vs human reviewer).
- Confirming the AI co-author trailer rule for free-text Jira fields
  (see also [`../git/commit_trailer.md`](../git/commit_trailer.md) for the
  commit-message equivalent).

## Related

- `../meta/instruction_authoring.md` — how rules are organized.
- `../../skills/setup/SKILL.md` — interactive setup for these integrations.
