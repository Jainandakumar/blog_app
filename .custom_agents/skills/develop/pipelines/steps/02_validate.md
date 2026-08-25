# Step 2: Validate

**Always runs.** For `ticket_type: local`, skip blocker/sibling/parent
checks — validate codebase parity only against user-provided
requirements.

**Pre-check — blockers (`jira` only).** If the Jira step reported
unresolved `is blocked by` links (tickets not in Done status), stop
development. Report which tickets are blocking and their current
status. In auto mode, stop and report. In interactive/guided, ask
whether to proceed anyway or wait.

**Cross-story verification.** If the ticket has `is blocked by` links
to tickets that ARE Done, the validate agent verifies their actual
output matches what this ticket's spec expects.

Launch a general-purpose Agent:

```
"Read `./agents/validate.md` for your instructions.

Context: [STRUCTURED CONTEXT — include requirements and criteria.
For Story tickets also include parent/sibling ticket summaries and
the architecture overview from the parent Feature. For
Bug/Spike/Task, parent and siblings are not loaded — those fields
will be absent.]
Workspace: [workspace path]
Local overrides: [relevant items from LOCAL.md]"
```

After the agent returns, apply mode logic:

- **Auto + explicit requirements + existing code found:** proceed
  using existing code where possible. Post Jira comment documenting
  parity findings.
- **Auto + vague requirements + existing code found:** post Jira
  comment, adjust plan to use existing features. Do not rebuild what
  exists.
- **Auto + sibling ticket covers it:** link as dependency if blocking,
  add Jira comment, exclude from this ticket's plan.
- **Auto + blocked:** link/create blocking ticket, post Jira comment,
  stop.
- **Interactive:** surface findings in chat and continue — no routine pause
  here (they inform the Plan Review gate). A real blocker still stops per the
  Pre-check above.
- **Guided:** record findings silently and continue; they appear in the
  commit-gate summary. A real blocker still stops per the Pre-check above.

Add `validation_results` to structured context.
