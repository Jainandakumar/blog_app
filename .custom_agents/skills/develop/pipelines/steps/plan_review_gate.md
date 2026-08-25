# Plan Review & Q&A gate (interactive only)

**Interactive mode only.** Skip in `guided`, `auto`, `headless`. This is a
gate, not a numbered step — it does not appear in the TodoWrite checklist.

After Design (Step 7) and before Code (Step 8), pause for the user to review
and shape the plan. Follow `./rules/develop/interactive_ux.md`.

1. Launch the `plan_summary` agent:

   ```
   "Read `./agents/plan_summary.md` for your instructions.

   Context: [STRUCTURED CONTEXT]
   Workspace: [workspace path]
   files_created: [from Architecture]
   files_modified: [from Design]
   Local overrides: [relevant items from LOCAL.md]

   Summarize the plan + skeletons for user review. Write
   [workspace]/implementation_summary.md."
   ```

2. Present the summary highlights inline using the Plan Review message in
   `./rules/develop/interactive_ux.md`, then run open Q&A in your
   context — answer from `plan.md`, `research.md`, and the stubbed files on
   disk.

3. Resolve with `AskUserQuestion`: **Proceed** / **Revise** / **Stop**.
   - **Proceed:** continue to Step 8.
   - **Revise:** apply the requested changes, then **repeat this gate**.
     - *Plan tweak:* update `[workspace]/plan.md`, re-run Architecture
       (Step 6) / Design (Step 7) as needed, re-present.
     - *New/changed requirement* (the user reveals something the ticket did
       not capture): fold it into `requirements`/`criteria` in structured
       context, re-plan, re-present. This is a **requirement change** —
       record it for Jira documentation per the General rules in
       `develop.md` and the status-vs-documentation rule (posted in every
       mode). Note that a requirement revealed only at review isn't
       verifiable against the ticket.
   - **Stop:** report and halt. The skeletons are on disk; the user can revert
     with `git checkout -- <files>` / `git clean` for a clean tree.

This gate replaces the former interactive pauses at Validate and Plan.
