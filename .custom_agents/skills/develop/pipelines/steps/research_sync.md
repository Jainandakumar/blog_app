# Research Sync (after Code)

**Runs in every mode**, after Code (alongside Documentation) and before
Test — an action, not a numbered step (no TodoWrite entry).

**Skip entirely if neither `[workspace]/research.md` nor
`[workspace]/topic_index.md` exists.** Most tickets never had `/research` or
a deep Spike run on them — this step costs nothing for the common case.

If either file exists, `/develop`'s own code changes are exactly the kind of
event that can make them stale — sync them now rather than waiting for a
future resume's `resume_verify.md` check to notice.

1. Reuse the changed-files list already computed by the Documentation step
   (`files_created` + `files_modified` from context, or
   `git diff --name-only develop...HEAD` if Documentation was skipped).
2. Launch `research_index.md` in its **scoped verify-or-update** mode:

   ```
   "Read `./agents/research_index.md` for your instructions.

   Mode: scoped verify-or-update
   Changed files: [LIST]
   Workspace: [workspace path]
   Ticket: [TICKET_KEY]"
   ```

   This checks and updates only the rows/entries in `topic_index.md` /
   `research.md` that reference the changed files — **not** a fresh topic
   crawl, **not** a new research process on the ticket.

Both files being absent is the common case (skip). Both being present is
handled by one launch — `research_index.md` updates whichever file(s)
actually exist and reference the changed files.

If it appended anything to `[workspace]/doc_review.md` or
`[workspace]/findings.md`, note the count in your run summary (status →
chat in interactive/guided; external in auto/headless) — same reporting
convention as the Documentation step.
