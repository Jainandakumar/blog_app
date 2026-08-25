---
last_reviewed: 2026-05-19
---

# Frontmatter specifications

The exact YAML frontmatter shape for each kind of instruction file. Referenced by `instruction_authoring.md` §7 and enforced by the `/author` skill.

---

## Skills (`./skills/<skill>/SKILL.md`)

```yaml
---
name: <skill-name>                          # required; matches the folder name
description: <one sentence>                 # required; ≤1,536 chars; key use case first
disable-model-invocation: true              # optional; set true for user-only skills
---
```

**Rules**
- `name` must match the parent folder. Mismatch breaks `/<name>` resolution.
- `description` is shown to the model when deciding whether to auto-invoke. Lead with the trigger phrase or use case, not a generic overview.
- `disable-model-invocation: true` for skills the user must always trigger explicitly (e.g. `/develop`, `/code-review`, `/author`).

**Example**

```yaml
---
name: author
description: Author or update  skills, agents, and rule files; enforces the conventions in ./rules/meta/
disable-model-invocation: true
---
```

---

## Agents (`./agents/<name>.md`)

```yaml
---
name: <agent-name>                          # required if invoked via Agent(subagent_type=<name>)
description: <when to use this agent>       # required if invoked via subagent_type
---
```

**Rules**
- `name` matches the file stem.
- `description` should describe **when** to use the agent, not **what** it does internally. The orchestrator picks based on this.
- For agents launched purely by reading the file and passing its content as a prompt, frontmatter is optional but recommended for consistency.

**Example**

```yaml
---
name: planning_research
description: Investigate prior art and reference implementations for a feature being planned. Use during planning sessions, not during active development.
---
```

---

## Rules (`./rules/<topic>/<subtopic>.md`)

Three frontmatter shapes — one per loading mode.

### Mode A — Explicit read + `MdExcludes` (default; most rules)

```yaml
---
last_reviewed: 2026-05-19
---
```

This frontmatter alone does **not** stop the file from loading into
every session and subagent —  Code has no "explicit read only"
state (see `instruction_authoring.md` §5). Every Mode A file must also
get a `MdExcludes` entry in `./settings.json`; `/author
audit` Check 5 flags any that don't.

### Mode B — Universal (loads every session; small foundational rules only)

```yaml
---
universal: true
last_reviewed: 2026-05-19
---
```

The `universal: true` flag is a marker for `/author audit` — it confirms the file's universal status is intentional. The decision log must contain an entry justifying why this rule qualifies for universal mode.

### Mode C — Path-scoped auto-attach (preferred whenever a real code-path binding exists)

```yaml
---
paths:
  - app/models/**
  - components/*/app/models/**
last_reviewed: 2026-05-19
---
```

**Rules**
- `last_reviewed` is required on all rule files. Bump when the rule's content is meaningfully reviewed against current reality, not just for typo fixes.
- `paths:` must cover the actual code locations the rule applies to. Test the globs against repo structure before committing.
- Don't combine `universal: true` with `paths:` — pick one mode.

---

## Feature docs (`docs/features/...`)

### Top-level feature (`docs/features/<feature>.md`)

```yaml
---
feature: <slug>                             # required; stable ID; matches the filename
summary: <one sentence>                     # required
paths:                                      # required; globs covering the feature's code
  - app/models/<feature>/**
  - lib/job_<feature>_*.rb
tags: [<tag>, <tag>]                        # required; for cross-reference search
related_features: [<feature_slug>]          # optional
last_reviewed: 2026-05-19                   # required
---
```

### Subtopic (`docs/features/<feature>/<subtopic>.md`)

```yaml
---
parent_feature: <slug>                      # required
summary: <one sentence>                     # required
paths:                                      # required
  - <glob>
last_reviewed: 2026-05-19                   # required
---
```

**Rules**
- `feature:` slug is referenced by YARD `@see` tags in code. Renaming is expensive — pick carefully on first creation.
- `tags:` are search hooks. Keep them few and stable.

---

## .md and AGENTS.md

No frontmatter. They're read as plain markdown by  Code and other tools.

If we adopt Anthropic's `@import` syntax in the future, references look like `@AGENTS.md` (no frontmatter change, just inline references). The current decision is separate-but-synchronized — see decision_log.md.
