---
name: <skill-name>
description: <one sentence — key use case first; truncated at 1,536 chars>
disable-model-invocation: <true if user-only, omit otherwise>
---

# `/<skill-name>` — <short title>

<One-paragraph description of what this skill does and when to use it.>

The conventions this skill must honor live in [./rules/meta/instruction_authoring.md](../../../rules/meta/instruction_authoring.md).

---

## Invocation

| Command | What it does |
|---|---|
| `/<skill-name>` | <interactive default> |
| `/<skill-name> <mode> [args]` | <direct dispatch if applicable> |

---

## Dispatch

<How the orchestrator routes based on arguments or interactive prompt.>

1. Parse the arguments.
2. Dispatch:
   - `<mode-a>` → read [pipelines/<mode_a>.md](pipelines/<mode_a>.md) and proceed.
   - `<mode-b>` → read [pipelines/<mode_b>.md](pipelines/<mode_b>.md) and proceed.

---

## Universal expectations

Before any dispatch:

- **Ensure `/setup verify` has succeeded for this session.** If `/setup` hasn't run, run it. The skill assumes external CLI tools are available.
- Read <which rule files>.
- Confirm <preconditions>.

Do NOT read pipeline files for modes you're not using.

---

## Reference reads

- `<path-to-rule-or-agent>` — <when/why>
- `<path-to-rule-or-agent>` — <when/why, conditional on X>

---

## Failure modes to watch for

- <Mode>: <symptom>: <action>.
- <Mode>: <symptom>: <action>.
