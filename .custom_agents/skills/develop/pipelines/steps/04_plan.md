# Step 4: Plan

**Always runs.**

## Safe update strategy check

Before launching the plan agent, check whether the ticket specifies a
safe update strategy (this will be in the description if the Feature
was planned with `/planning`). Look for:

- A "Safe Update Strategy" section naming the strategy type and toggle
  name.
- References to a feature toggle name (e.g., `:new_enrollment_flow`).

If found, add to structured context:

```
safe_update_strategy: [Feature Toggle | Parallel Change | etc.]
toggle_name: [if Feature Toggle, e.g., :new_enrollment_flow]
```

If the ticket modifies existing behavior but does NOT specify a
strategy, see `./rules/planning/safe_update_strategy.md` for the
options and selection rules:

- **Interactive/guided:** present the options from the shared rule and
  ask the user which strategy to use.
- **Auto:** use Feature Toggle as the safest default per the shared
  rule. Story: search the current ticket, parent Feature, and sibling
  tickets for an existing toggle name. Bug/Spike/Task: search the
  current ticket's description and comments only. If no toggle name
  found, stop and ask the user — do not invent a toggle name.

## Plan agent

```
"Read `./agents/plan.md` for your instructions.

Context: [STRUCTURED CONTEXT]
Workspace: [workspace path]
Local overrides: [relevant items from LOCAL.md]

Create a structured implementation plan. Write it to
[workspace]/plan.md. Research the codebase as needed.

Migration check: if this ticket requires database migrations, check
for pending migrations on the current branch (`ls db/migrate/`) and
note any that touch the same table. Flag potential conflicts in the
plan."
```
