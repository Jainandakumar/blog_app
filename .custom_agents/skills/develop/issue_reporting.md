# Issue reporting

When any of the following happen during the pipeline, launch the
`report_issue` agent so the issue gets captured for the AI-instruction
maintainer:

- A subagent returns `NEEDS_DECISION` AND the question reveals an
  instruction gap (the docs didn't cover the case).
- The user issues a correction like "you should have done X instead" —
  log it so the rule lands in `./rules/` or `LOCAL.md` later.
- A step fails in a way not covered by existing error handling
  (malformed MCP response, unexpected hook result).

Launch with:

```
"Read `./agents/report_issue.md` for your instructions.

Context: <one sentence — what was happening>
Issue: <what went wrong>
Category: instruction-gap | instruction-wrong | unexpected-failure | user-correction
Suggested fix: <which file should change and how>
Ticket: [TICKET_KEY]
Workspace: .workspace/[TICKET_KEY]"
```

The agent appends a structured entry to a local-only
`.workspace/issue_log.md` (the file is gitignored; each developer has
their own log). At the end of the pipeline, report the count:
"N instruction issues logged to `.workspace/issue_log.md` (local-only)."

A follow-up will route these entries to GitHub Issues — see the
decision-log entry "issue_log.md is local-only pending GitHub Issues
integration."

**Do NOT** invoke `report_issue` for transient errors (network,
rate-limit, auth) or for routine SKIPs.
