---
last_reviewed: 2026-05-19
---

# Codebase exploration strategy

Shared strategy for any agent that explores the existing codebase to find
patterns, related files, and reusable building blocks (research, planning
research, spike code-research phase).

## Exploration strategy

1. **Start broad.** Use `Glob` to find file patterns in the affected areas.
2. **Search for related code.** Use `Grep` for class names, method names, or
   domain terms.
3. **Read key files.** Understand the existing implementation — read full
   files, not just hits, when the file is short enough.
4. **Check tests.** See how similar features are tested; that's where the
   contract is documented.
5. **Look for reusable building blocks.** Utilities, concerns, base classes
   the new code should inherit from or include.

## What to look for

- **Existing patterns.** How does the codebase already handle similar
  functionality? New code should follow the same pattern unless there's a
  specific reason not to.
- **Related files.** What other files interact with the affected areas?
  A change in one model often ripples to controllers, views, and jobs.
- **Base classes / concerns.** Are there base classes or concerns the new
  code should use? Reusing them costs nothing; reinventing them risks
  divergence.
- **Test patterns.** How are similar features tested? What test helpers
  exist? FactoryBot factories, request-spec helpers, custom matchers.
- **Naming conventions.** How are similar classes/methods/files named?
  Match the existing pattern rather than introducing a new one.

## How depth scales with task type

| Task | Depth |
|---|---|
| Single-ticket plan research | Just the affected files plus immediate callers |
| Feature-scope planning research | All files in the feature's domain, including peer features that may need migration |
| Spike research | Everything that bears on the research question, including full call chains and version history |

## What to *not* do during exploration

- Don't modify any files. Exploration is read-only.
- Don't make style/design decisions. If you spot a conflict, surface it; don't
  resolve it.
- Don't propose architecture or method signatures. That's the Architecture and
  Design agents' job.
