---
last_reviewed: 2026-05-19
---

# NEEDS_DECISION return protocol

The recurring "if you can't proceed, return `NEEDS_DECISION: …`" block in agent files. Every subagent file in `./agents/` carries this protocol so callers (orchestrators or the user) get a clear escalation signal.

## Purpose

A subagent that hits a question outside its allowlist (see `documents_allowlist.md`) or outside its CRITICAL CONSTRAINTS (see `critical_constraints.md`) must NOT guess. Guessing breaks the role boundary — the Code agent decides routes, the Design agent decides implementation, etc. Returning `NEEDS_DECISION` hands the question back to the caller (or, via the caller, to a different agent or the user).

This is the escalation half of the explicit-read discipline. The allowlist defines what the agent can answer with; `NEEDS_DECISION` defines what to do when it can't.

## Shape

```markdown
## NEEDS_DECISION Protocol

If you encounter something not covered by your designated docs:

```
NEEDS_DECISION: [Your specific question]
```

**Examples:**
- `NEEDS_DECISION: <a real question this agent would actually hit>`
- `NEEDS_DECISION: <another>`

Do NOT guess. Do NOT create new <thing this agent is forbidden to create>. Return NEEDS_DECISION and wait.
```

## Rules for content

- **Specific examples beat generic.** "NEEDS_DECISION: a question I can't answer" is useless. Provide 2–3 examples that mirror the agent's actual role-collision points (Code agent escalates route decisions to Architecture; Test agent escalates "mock or VCR" to caller).
- **State what the agent must not do.** The "Do NOT guess. Do NOT create new X" line restates the CRITICAL CONSTRAINTS in the escalation context — it's the moment the constraint gets tested.
- **Single-line output format.** `NEEDS_DECISION: <one sentence>`. The caller scans for this token; multi-line outputs hide it.
- **The agent stops after returning NEEDS_DECISION.** It does not keep working "with a placeholder until we hear back." The caller routes the question and resumes the agent later.

## Caller responsibility

The caller (the orchestrator skill or the main session) is responsible for:

1. Detecting the `NEEDS_DECISION:` token in the agent's output.
2. Routing the question to the right answerer (another agent or the user).
3. Resuming the original agent with the answer.

Agent files don't describe this — they only describe how to *emit* `NEEDS_DECISION`. The routing is the caller's job.

## When to use

Use this pattern in every subagent file in `./agents/`. The main session (orchestrator) does not return `NEEDS_DECISION` to itself — when it's blocked, it asks the user directly per `communication.md`.
