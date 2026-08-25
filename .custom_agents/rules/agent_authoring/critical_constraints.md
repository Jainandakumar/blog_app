---
last_reviewed: 2026-05-19
---

# CRITICAL CONSTRAINTS section

The recurring section shape in agent files that names the agent's hard limits up front. Every subagent file in `./agents/` opens with this section.

## Purpose

A subagent's scope is enforced by what it is *forbidden* to do, not just what it is told to do. The CRITICAL CONSTRAINTS section is the agent's hard boundary — the things it must not do even if the prompt seems to invite them. Without it, agents drift into adjacent roles.

## Shape

```markdown
## CRITICAL CONSTRAINTS

**<One-sentence statement of scope.>** You:
- <thing the agent does>
- <thing the agent does>

**Do NOT:** <thing the agent must never do>, <thing>, <thing>.

**Why:** <one sentence — why this boundary protects the workflow>
```

The "Do NOT" line is the load-bearing part. The bullet list of what the agent *does* is for orientation; the prohibition is the constraint.

## Rules for content

- **One scope sentence.** Lead with the agent's role in one sentence ("You implement controller actions. You do NOT create new classes or define public interfaces.").
- **Forbid actions, not files.** "Do NOT write tests" is a constraint. "Do NOT touch spec/" is a file rule and belongs in the agent's allowlist instead — see `documents_allowlist.md`.
- **Always include the Why.** A constraint without justification gets ignored when the agent encounters edge cases. One sentence is enough.
- **Place at the top.** Right after the H1 and the one-line scope, before "Your Job" or any procedural content. The constraint must load before the agent reads anything that might tempt it across the line.

## When to use

Use this pattern in every subagent file in `./agents/`. If the constraint list would be empty, the agent's scope is probably too broad — consider whether the work could be done inline by the caller instead.

## When NOT to use

- Skills (the orchestrator entry) don't have CRITICAL CONSTRAINTS — they describe a workflow, not a single-role boundary.
- Rule files don't have CRITICAL CONSTRAINTS — rules describe facts, not actions.
