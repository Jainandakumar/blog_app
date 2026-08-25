---
last_reviewed: 2026-05-19
---

# AI co-author trailer

When the AI authored or substantially shaped a free-text body, append an
AI co-author trailer at the end. This rule applies to two surfaces:

1. **Git commit messages** — when the AI wrote the commit message body.
2. **Jira free-text fields** — `mcp__jira__add_comment.body` and
   `mcp__jira__create_issue.description`.

The trailer is a portable convention that lets reviewers immediately see when an
AI shaped the text. Skip the trailer only when the user supplied the text
verbatim.

## Trailer format

### In commit messages

The trailer block must be the **last** paragraph of the commit message so
`git interpret-trailers` and other Git tooling recognise it correctly:

```
MDP-NNNNNN Brief description

Body paragraph(s) explaining what changed and why.

Co-Authored-By: <model name> <noreply@anthropic.com>
```

### In Jira free-text bodies

Append the trailer at the end of the body in italics, separated by a horizontal
rule, since `add_comment` and `create_issue` accept markdown:

```

---
*Co-Authored-By: <your model name> <noreply@anthropic.com>*
```

## When to skip

- The user typed the comment/description verbatim and you're posting it as-is.
- You're updating an existing comment (the trailer is on the original; don't
  duplicate).

## When NOT to skip

- You drafted, summarised, or expanded the body.
- You translated user notes into a Jira-shaped comment.
- You generated the commit message from a diff.
