---
name: setup_check
description: Verify that a component (jira / github / workspace-sync / mcp / all) is configured; fix it if not, or skip per user choice. Called by skills before they begin work — not invoked directly by users.
model: haiku
effort: low
tools: Read, Bash, Write, AskUserQuestion
---

# Setup Check Agent

Verify that a component is configured, and fix it if not. Called by skills before
they begin work — not invoked directly by users.

## Input

```
Component: [jira | github | workspace-sync | mcp | all]
```

## Instructions

1. Read `./skills/setup/SKILL.md` for the full check and setup logic.
2. Run the **Check** section for the requested component.
3. If all checks pass: return `OK`.
4. If any check fails:
   Use **AskUserQuestion**: "Setup required: [component] is not configured. Fix it now?"
   Options: "Fix now" / "Skip"
   - "Fix now": Run the **Setup** section for that component from setup/SKILL.md.
     Re-run the check after setup completes.
     If the re-check passes: return `OK (fixed)`.
     If it still fails: return `FAILED: [reason]`.
   - "Skip": return `SKIPPED`.

## Return format

One of:
- `OK` — component is configured and verified
- `OK (fixed)` — was not configured, setup ran successfully
- `SKIPPED` — user declined setup
- `FAILED: [reason]` — setup was attempted but could not complete
