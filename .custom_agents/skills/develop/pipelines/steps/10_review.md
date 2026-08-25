# Step 10: Review

**Orchestrate code-review inline** — read
`./skills/code-review/orchestrator_instructions.md` and follow
all steps yourself. Do NOT wrap it in a wrapping subagent (that would
silently halt because subagents in this environment cannot spawn the
review/fix subagents that orchestrator_instructions.md launches). Do
NOT invoke the `/code-review` skill — that path also wraps via
SKILL.md and would create the same problem. The review and fix
subagents are launched directly from your top-level context, and per
orchestrator_instructions.md the full review report is written to
`[workspace]/code_review.md` so only summary fields return to your
orchestrator context.

## Retry loop

Track `review_fix_attempts: 0` in structured context. Each iteration:

1. Run the code-review pipeline inline by following
   `./skills/code-review/orchestrator_instructions.md` with this
   context:

   ```
   Mode: [MODE]
   Ticket context (for requirements verification):
     ticket: [TICKET_KEY]
     requirements: [REQUIREMENTS]
     criteria: [ACCEPTANCE CRITERIA]
     safe_update_strategy: [STRATEGY and toggle name, if applicable]
     workspace: [WORKSPACE PATH]
   ```

   The instructions tell you when to launch the review subagent
   (Standard or batched per Large strategy) and when to launch the fix
   subagent — those are single-level launches from your top-level
   context.

2. When orchestrator_instructions.md completes, capture from your own
   state:
   - `remaining_critical_issues: N` — unfixed Critical issues + Pronto
     E/F errors.
   - `needs_architectural_change: [list or "none"]` — issues requiring
     new classes, public methods, or migrations.

3. If `needs_architectural_change` is not empty: route each issue using
   the same NEEDS_DECISION routing as Step 8 (Architecture → Design →
   Code as needed). Reset `review_fix_attempts = 0` and reenter the
   loop after routing is complete.

4. If `remaining_critical_issues == 0` → continue to Step 11.

5. Increment `review_fix_attempts`. If `review_fix_attempts < 3` →
   repeat from step 1.

6. If `review_fix_attempts >= 3` → same stuck flow as Step 9: present
   a report of remaining issues and what was tried, then
   `AskUserQuestion` with the same three options
   (`Try Again` / `Review the Problem With ` /
   `I'll Fix It Myself`), with the same interactive-debug routing and
   counter reset logic. See `09_test.md` "Stuck flow" for the script
   shape.
