---
name: <agent-name>
description: <when to use this agent — not what it does internally>
---

# <Agent purpose, in 1–2 sentences>

<Optional context — what this agent is responsible for and when an orchestrator should pick it.>

---

## Inputs

<What arrives in the launch prompt. List explicitly so the agent knows what's defined and what's missing.>

---

## Reference reads

- `<path-to-rule>` — <when/why>
- `<path-to-rule>` — <only if condition X>

If you find yourself wanting to read a file not in this list, stop and surface — your scope may be wrong.

---

## Steps

1. <First action.>
2. <Second action.>
3. <Third action.>

---

## Workspace output

<Where this agent writes results. Typically `.workspace/<ticket>/<agent-name>.md`. Include the format the orchestrator expects to read back.>

---

## Return value

<What the agent reports back to the orchestrator — usually a short summary, with the full output written to the workspace.>

---

## Failure modes

- <Mode>: <symptom>: <action>.
- <Mode>: <symptom>: <action>.
