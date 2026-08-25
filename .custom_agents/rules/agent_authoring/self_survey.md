---
last_reviewed: 2026-08-11
---

# Self-survey mechanics

How and where a subagent answers the fixed self-survey questions in
[`self_survey_questions.md`](self_survey_questions.md). Wired in via
[`workspace_output.md`](workspace_output.md) — every agent that follows
that pattern also does this, in the same step, right before returning.

## When

Once per subagent run, immediately before you write your return summary —
not mid-task, not multiple times. Use only what's already in your context
from this run.

## Where the answer goes

Write to a new file:

```
[workspace]/self_survey/{timestamp}_{agent}.md
```

- `{timestamp}` — `date -u +%Y%m%dT%H%M%SZ` (UTC, filesystem-safe — no
  colons).
- `{agent}` — your own agent name (the file stem of your instructions,
  e.g. `research`, `code_business_logic`).

One file per run, never appended to or overwritten — this is what lets
someone browse `self_survey/` and see every answer as its own dated
entry, one per pipeline step.

## File format

```markdown
---
agent: [your agent name]
model: [your model, e.g. "Sonnet 5"]
ticket: [TICKET_KEY, or the workspace folder name if not a ticket]
timestamp: [ISO-8601 UTC]
reviewed: false
---

1. [answer]
2. [answer]
3. [answer]
4. [answer]
5. [answer]
6. [answer]
7. [answer]
```

`model` is your actual running model, not necessarily your pinned
default — read it from your own system prompt's "You are powered by the
model named ..." line (same mechanism `model_assessment.md` uses). This
can differ from the model declared in your own agent frontmatter if the
orchestrator overrode it at launch (model escalation, subagent
downgrade) — the system-prompt value is ground truth.

`reviewed: false` is a placeholder field for a future consumer — no
process reads or updates it yet. Leave it as `false`; don't build
reviewing logic now.

## Secrets and PII

Survey answers sync to the shared workspace repo like any other workspace
file (`./rules/planning/workspace_sync.md`). Never inline a real
secret, token, or PII value into an answer — describe the problem instead
("the API response included what looked like a customer SSN in
plaintext," not the SSN itself). See
[`../security/business_logic.md`](../security/business_logic.md) for the
PII handling this extends, and `workspace_sync.md`'s "Secrets in the
workspace" section for the `.secrets` convention if a value genuinely must
persist (rare — a survey answer almost never needs to).

## Ticket-validity gate

Same gate as sync itself: if the workspace is under a `LOCAL-` ticket or
isn't a synced ticket workspace at all (e.g. `/document`'s fixed
`.workspace/document_session/`), still write the file — it's useful for
local review — it just won't travel anywhere, same as the rest of that
workspace.

## Related

- [`self_survey_questions.md`](self_survey_questions.md) — the questions
  themselves.
- [`workspace_output.md`](workspace_output.md) — the shared return
  pattern this hooks into.
- [`../planning/workspace_sync.md`](../planning/workspace_sync.md) — how
  these files travel to the shared workspace repo, and the secrets
  convention referenced above.
