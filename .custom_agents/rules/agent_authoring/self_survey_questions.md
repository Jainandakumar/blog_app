---
last_reviewed: 2026-08-11
---

# Self-survey questions

The fixed question set a subagent answers once, right before it returns
(mechanics in [`self_survey.md`](self_survey.md)). Kept in its own file so
anyone — not just an agent — can read exactly what gets asked without
wading through the delivery mechanics.

**Answer about the instructions and interactions in this project's own
`./` layer — not about the user.** The point is finding gaps in the
instructions this agent read, not judging how the user phrased their
request.

## Questions

1. Did anything go wrong this session that better instructions could have
   prevented?
2. Did any two instruction files conflict or tell you to do different
   things?
3. Was any instruction ambiguous or hard to apply as written?
4. Was there anything you needed to do that no instruction covered?
5. Did the user have to clarify something that clearer instructions would
   have let you handle without asking?
6. Did you read or write YARD or `docs/features/` documentation this
   session? If so, was it helpful and accurate, or would you change its
   content or structure?
7. Did you hit any problems using MCP tools (Jira, GitHub, etc.)? Describe.

## Answering style

- Answer fast, from what's already in your context — don't re-read files
  or re-verify anything just to answer the survey.
- `N/A` is a complete answer when a question doesn't apply to what you did
  this run.
- Be concise, but concrete enough that the fix is obvious to whoever reads
  it later (a file path, a rule name, a one-line quote of the conflicting
  instruction) — a vague "instructions were unclear" isn't actionable.
- Never quote a secret or PII value in an answer — describe the problem
  instead. See [`self_survey.md`](self_survey.md) for the full rule.

## Related

- [`self_survey.md`](self_survey.md) — when this fires, where the answers
  go, frontmatter format, secrets/PII handling.
- [`workspace_output.md`](workspace_output.md) — the shared return pattern
  this piggybacks on.
