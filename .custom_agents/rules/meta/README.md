---
last_reviewed: 2026-05-19
---

# Meta — rules about authoring instruction files

This folder holds the canonical conventions for the AI-instruction layer (`./skills/`, `./agents/`, `./rules/`, and the root `.md`/`AGENTS.md`).

When in doubt while authoring or updating an instruction file, invoke the `/author` skill — it enforces these conventions.

## Files

| File | Purpose | When to read |
|---|---|---|
| [instruction_authoring.md](instruction_authoring.md) | The 12 conventions for skills, agents, rules | When authoring or auditing any instruction file |
| [content_discipline.md](content_discipline.md) | What content belongs in an instruction file — when to include WHAT/HOW/WHY/DON'T, with positive and negative examples | When writing or reviewing instruction-file prose |
| [frontmatter_specs.md](frontmatter_specs.md) | Full YAML frontmatter schemas + examples | When creating a new skill/agent/rule, or fixing frontmatter errors |
| [cross_references.md](cross_references.md) | How `@see` (code→doc) and `paths:` (doc→code) link the two | Universal — loaded every session by Mode B |
| [decision_log.md](decision_log.md) | Append-only log of convention decisions with rejected alternatives and reasoning | When considering an override, or trying to understand why a convention exists |

## How to use this folder

- Don't edit conventions in `instruction_authoring.md` without a decision-log entry.
- New universal rules require a decision-log justification.
- Splitting/merging files counts as a convention change → log it.
