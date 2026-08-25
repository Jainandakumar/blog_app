---
last_reviewed: 2026-08-10
---

# Jira comment/description size limits

Jira Cloud enforces a hard **32,767-character cap on the serialized ADF
JSON payload** for both comments and issue descriptions — the limit
applies to the underlying document structure, not the visible markdown or
plain text. [Source](https://support.atlassian.com/atlassian-cloud/kb/commentbodycharacterlimitexceededexception-no-message-or-the-entered-text-is-too-long-it-exceeds-the-allowed-limit-of-32-767-characters-error-message-in-jcma/).

## Measured JSON overhead

The markdown-to-ADF converter (`mcp/atlassian`'s `lib/adf.js`) wraps every
heading, bold span, list item, and table cell in its own JSON node, so the
serialized size runs well above the source text length. Measured against
the actual converter:

| Content mix | JSON ÷ source ratio |
|---|---|
| Prose-only (headings, bold labels, paragraphs) | ~1.45x |
| Prose + tables + fenced code blocks | ~2.2x |
| A checklist `taskList` alone, short one-line items | ~1.7x |

## Safe budget

Target **15,000 characters of markdown/text source per comment**,
counting everything that will go into one `add_comment` or
`post_feature_review_checklist` call together. This leaves margin across
the overhead range above, including the code/table-heavy case.

## Splitting pattern (when content won't fit in one comment)

1. Post the primary comment first — whatever must stay intact (e.g. a
   checklist `taskList` never splits across comments) plus a short pointer
   noting the rest follows in separate comments.
2. Split the remaining content into as many follow-up comments as needed,
   only on natural section/entry boundaries — never mid-entry.
3. Each follow-up comment:
   - Carries the **same header** as the primary comment.
   - Adds a `(detail N of M)` line under the header.
   - Links back to the primary comment via its returned `url`
     (`...?focusedCommentId=<id>`).
   - Ends with whatever footer/trailer the primary comment used.

## Related

- `./agents/feature_review_synthesis.md` — current consumer of this
  pattern (Feature-review Jira checklist comment).
- `./rules/git/commit_trailer.md` — the AI co-author trailer
  appended to each comment, including split-off follow-ups.
- `./rules/integrations/jira_api.md` — Jira MCP tool reference.
