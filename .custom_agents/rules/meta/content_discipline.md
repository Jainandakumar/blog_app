---
last_reviewed: 2026-05-20
---

# Content discipline — what belongs in an instruction file

When you write or update a skill, agent, or rule file, every sentence costs context for the agents that will read it. Content that doesn't help the reader do its job — and especially content that introduces out-of-scope concepts — actively hurts.

This rule lists what content belongs and what doesn't, with worked examples.

---

## The framework

| Content type | When to include |
|---|---|
| **What to DO** (in-scope action) | **Always** — this is why the instruction exists |
| **What NOT to do** (clarifying a pattern, or preventing a likely mistake) | **Sometimes** — only if it sharpens the in-scope work |
| **HOW to do it** (specific command or required invocation) | **Always** when one way is required; **sometimes** for implicit patterns |
| **WHY** (workflow context, agent boundaries) | **Sometimes** — when the agent would make a different choice without it |
| **What NOT to do** (out-of-scope) | **Never** |
| **WHY** (business decisions, out-of-scope) | **Never** |

---

## What to DO — always

The core. Every instruction needs a clear statement of the action.

---

## What NOT to do — sometimes (and only when it helps)

### Good: clarifies a pattern with positive AND negative cases

```
Good: extract repeated logic to a helper method.
Bad:  nest the conditional three levels deep.
```

Both shape the agent's decision space. The "bad" makes the "good" concrete.

### Good: clarifies a role boundary the agent might otherwise cross

```
Your job is researching the code to find similar implementations,
NOT writing new code yourself.
```

Prevents scope creep within the agent's existing context.

### Maybe: prevents a likely mistake

If we observe (or strongly expect) the agent might do something we don't want, a "don't" can save us:

```
Don't read files in `lib/` — that directory is out of scope for this task.
```

Add this only if the agent's current scope makes the mistake plausible. If `lib/` isn't in the agent's reference reads or grep paths, it isn't going there — forbidding it just plants the seed.

### Bad: unrelated negative cases

```
Your job is searching the web for information on X.
Do not remove files from the codebase.
```

The agent is a researcher — file removal was never on the table. Naming it just introduces "removing files" to its context.

### Bad: obvious or implicit boundaries

```
You may read any file in the project, but don't read files outside
the project folder.
```

Reading outside the project wasn't on the table. Naming it adds noise.

---

## HOW to do it

### Always — specific commands or required invocations

```
Run Pronto with the project runners: `bin/pronto run -r brakeman rubocop -f json`.
```

```
Use the Edit tool to modify files, not heredocs or `cat`.
```

There's one right way; spelling it out removes ambiguity.

### Sometimes — implicit patterns easy to skip

```
Run `bundle install` before specs.
```

Idempotent and recoverable on failure, but easy to forget. Include if you've seen the omission cause friction.

---

## WHY — sometimes

### Workflow context (when behavior depends on knowing the reason)

```
Use dot-numbering for sub-items (1.1.1.1.1) — the planning skill
parses this format later.
```

The format matters because a downstream consumer reads it. Without the why, the agent might "improve" it.

### Agent boundaries (when adjacent responsibilities aren't obvious)

```
Don't write the controller code — that's the Code: API agent's job
after the model changes are merged.
```

Include when two agents have neighboring responsibilities and the boundary isn't visible from the action description alone.

---

## What NOT to do — never (out-of-scope items)

Don't list "don't do X" for things the agent had no path toward. Each one introduces X to the context.

Examples that **don't belong** in instruction files:

- "Don't connect to the NAS via SSH" — no NAS-related work anywhere; the agent now thinks about NAS.
- "Don't modify production data" — the agent has no production access.
- "Don't email the user" — the agent has no email capability.

If a constraint is implicit from the absence of capability or context, it doesn't need to be stated.

---

## WHY — never (out-of-scope business reasoning)

Don't explain business decisions the agent isn't being asked to make.

```
NOT helpful in a generic agent:
"We use email as the username because [historical reason]."
```

Include such reasoning only in the specific instruction file dealing with user/username work, and only if the agent might otherwise make a different choice.

---

## Self-check when authoring

Before adding a "don't do X" or "we do Y because Z" line, ask:

1. Was the agent already in a position to do X (or already aware of Z)?
2. Would the agent likely make the wrong choice without this line?
3. Does this introduce a concept the agent wasn't already working with?

If **1 = no**, or **3 = yes**, leave it out.

---

## Related rules

- [instruction_authoring.md](instruction_authoring.md) — overall conventions (esp. §8 no duplication, §5 explicit reads).
- [`./rules/agent_authoring/critical_constraints.md`](../agent_authoring/critical_constraints.md) — when a CRITICAL CONSTRAINTS block IS appropriate.
