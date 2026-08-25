---
last_reviewed: 2026-05-19
---

# Jira status rules

Each Jira issue type has specific valid statuses for **starting work** and for
**advancing on completion**. This rule is the single source of truth for those
transitions; skills and agents that fetch or transition a ticket reference it
instead of restating the table.

Only check or change the status of the ticket you are working on — never check
or change the parent ticket's status.

---

## Per-issue-type matrix

| Type | Valid start status | Transition to (start-of-work) | On completion, advance to |
|------|--------------------|-------------------------------|---------------------------|
| **Spike** | "Planning" or "In Progress" | In Progress (from Planning) | Done |
| **Task** | "Planning" or "In Progress" | In Progress (from Planning) | Done |
| **Story / Bug** | "Ready for Development" or "Development" | Development (from Ready for Development) | Testing (QA) |
| **Feature** | "Planning" or "In Progress" | — (don't change) | — (don't advance) |
| **Initiative** | "In Progress" | — (don't change) | — (don't advance) |

---

## Start-of-work logic

1. The current status comes from the ticket fetch (`mcp__jira__get_issue`
   response field `status`).
2. Look up the row for the ticket's `issuetype` in the table above.
3. Decide:
   - **Already in the target work status** (e.g., Story already in
     "Development"): no transition needed. Proceed.
   - **In the valid starting status** (e.g., Story in "Ready for
     Development"): execute the transition to the target work status.
   - **Anything else** (e.g., Story in "Planning"): **do NOT transition**.
     Warn the user — someone else was responsible for moving the ticket to
     the correct status. Offer to continue anyway, but never silently
     reassign workflow ownership.

### Transition call

```
mcp__jira__transition_issue(issue_key: "[TICKET_KEY]", to_status: "[TARGET]")
```

---

## End-of-work logic

After the corresponding work has been verified (merged code, completed
research write-up, etc.):

- **Spike / Task** → advance to **Done**.
- **Story / Bug** → advance to **Testing** (QA owns the ticket from there).
- **Feature / Initiative** → do not change. These are container types; their
  statuses are advanced by humans (PMs, leads) based on child-ticket
  completion, not by automation.

If the end-of-work transition fails (required fields missing, workflow
permission), surface the error to the user with a direct ticket link
(`https://plansource.atlassian.net/browse/[TICKET_KEY]`). Never populate
required fields automatically — the human owns that decision.

---

## Handling transition errors

If `mcp__jira__transition_issue` returns an error (e.g., required fields
missing):

1. Tell the user exactly what the error said.
2. Provide a direct ticket link.
3. Do NOT attempt to auto-populate required fields.
4. If the user says they fixed it, re-fetch with `mcp__jira__get_issue` to
   verify the new status. If the status still hasn't changed, ask for
   explicit confirmation before continuing.

---

## Related

- [`README.md`](README.md) — jira-rules folder index.
- [`../integrations/jira_api.md`](../integrations/jira_api.md) — MCP tool
  reference for `mcp__jira__get_issue` and `mcp__jira__transition_issue`.
