---
last_reviewed: 2026-05-19
---

# Documents-You-May-Read allowlist

The recurring "for guidelines, read ONLY these docs" block in agent files. Subagent files in `./agents/` that need to read shared rules carry this allowlist to enforce the explicit-read discipline.

## Purpose

A subagent's context size is bounded by what it reads. Without a stated allowlist, agents browse — picking up content for adjacent roles, blowing past the soft 200-line target, and drifting toward work outside their scope. The allowlist makes the agent's read-set explicit and predictable.

This is the **Mode A (explicit read)** discipline from `meta/instruction_authoring.md` §5 — the allowlist is how the discipline shows up inside an agent file.

## Shape

```markdown
## CRITICAL CONSTRAINTS

**<scope sentence>**

**For guidelines, read ONLY these docs:**
- `./rules/<topic>/<file>.md` — <what this rule covers, one phrase>
- `./rules/<topic>/<file>.md` — <what this rule covers, one phrase>
- `./rules/<topic>/<file>.md` — <what this rule covers, one phrase>

**Why:** <one sentence — what staying inside this set protects>
```

Conditional reads are fine ("only if X") — the condition must be explicit, not "browse for relevance."

## Rules for content

- **Path-prefix everything.** Full repo-relative path (`./rules/…`), not a bare filename. The agent will be invoked from many working directories; ambiguity costs a wrong read.
- **Annotate each entry.** One phrase after the em-dash describing what the rule contributes. Without it, the list becomes opaque on re-reads.
- **Aim for ≤8 entries.** If the agent legitimately needs more than ~8 rule files, its scope is too broad — split the agent rather than expand the allowlist.
- **No `docs/` paths.** All shared rules live under `./rules/` after the migration. Allowlists that still point at `docs/` are stale.
- **No nested-folder browsing.** "Read `./rules/architecture/` for context" is browsing; list the specific files instead.

## When to use

Use this pattern in every subagent file in `./agents/` that needs to read shared rules. The corollary: every rule the agent reads should be listed here; conversely, the agent should not read rules not listed here.

## When NOT to use

- For agents whose entire job is to *find* information (Research agent), the allowlist is unhelpful — they need `Read`, `Glob`, `Grep` over the whole codebase by definition. State that explicitly instead: "You may read any file in the codebase; you do not read other agents' rule files."
- Skills don't carry this allowlist directly. Skills should reference the subagent files, which carry it.
