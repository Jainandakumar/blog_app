# Documentation (after Code)

**Runs in every mode**, after Code and before Test — an action, not a numbered
step (no TodoWrite entry). Feature docs and YARD are authored **together** in
one pass so the `@see` ↔ `paths:` link stays consistent; see
[`../../../../rules/documentation/feature_docs.md`](../../../../rules/documentation/feature_docs.md).

Determine the changed files (branch diff — `files_created` + `files_modified`
from context, or `git diff --name-only develop...HEAD` plus staged/unstaged).

1. **Feature docs first** — launch `document_feature`:

   ```
   "Read `./agents/document_feature.md` for your instructions.

   changed_files: [LIST]
   functional_area: [from structured context; empty if none]
   jira_context: [workspace]/jira_context.md
   workspace: [workspace path]
   ticket: [TICKET_KEY]
   Local overrides: [relevant items from LOCAL.md]"
   ```

2. **Then YARD** — launch `document_yard` on the changed `.rb` files (exclude
   `spec/**`, `test/**`, `db/migrate/**`); it verifies/completes YARD and wires
   each entry-point class's `@see` to the docs `document_feature` just set
   `paths:` on:

   ```
   "Read `./agents/document_yard.md` for your instructions.

   Files to document: [CHANGED .rb FILES]
   Workspace: [workspace path]
   Local overrides: [relevant items from LOCAL.md]"
   ```

Both are idempotent verify-or-enhance passes — most runs touch little. For
`ticket_type: local` (no `functional_area`), `document_feature` resolves docs
by `paths:` match and flags gaps; it does not bootstrap. If `document_feature`
appended items to `[workspace]/doc_review.md`, note the count in your run
summary (status → chat in interactive/guided; external in auto/headless).
