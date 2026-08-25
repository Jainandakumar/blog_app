---
last_reviewed: 2026-08-03
---

# Jira MCP tool reference

Jira operations use MCP tools — no credentials, curl, or ADF required.
Auth, ADF encoding, and rate limiting are all handled internally by the tools.

Use the following MCP tools for all Jira work:

| Tool | Purpose |
|------|---------|
| `mcp__jira__check_auth` | Verify credentials and API connectivity |
| `mcp__jira__get_issue` | Fetch ticket details — returns parsed fields, no raw ADF |
| `mcp__jira__transition_issue` | Advance ticket status by name |
| `mcp__jira__add_comment` | Post a comment (accepts plain text or markdown) |
| `mcp__jira__post_feature_review_checklist` | Post or update a comment with a real, checkable checklist (ADF task list) plus surrounding prose. Use for any workflow that re-reviews the same ticket over time and needs items markable done across runs — `add_comment`'s markdown conversion does not turn `- [ ]` into a real checkbox. |
| `mcp__jira__update_acceptance_criteria` | Check off completed AC items |
| `mcp__jira__update_bug_fields` | Update Bug-specific custom fields |
| `mcp__jira__update_issue` | Ad-hoc edits to an existing ticket (summary, description, AC, priority, parent, etc.). Posts a permanent audit comment. Prefer the narrower tools above when working inside a documented skill workflow; use this only when the user explicitly asks for a modification outside that flow. |
| `mcp__jira__create_issue` | Create a new Jira ticket |
| `mcp__jira__create_issue_link` | Link two tickets |
| `mcp__jira__download_attachment` | Download an attachment to a local path |

No credentials or ADF ever appear in a tool call. If a tool returns
`{error: "Auth failed"}`, report: "Jira not configured. Run /setup jira."

## Authoring conventions

When you (the AI) authored or substantially shaped a free-text body, append
the AI co-author trailer per [`../git/commit_trailer.md`](../git/commit_trailer.md).
Applies to: `add_comment.body`, `create_issue.description`. Skip only when the
user supplied the text verbatim.
