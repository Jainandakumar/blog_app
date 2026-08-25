# Step 13: Merge (auto mode only, `ticket_type: jira` only)

**Skip if `ticket_type: local`** (no MR to merge).

After the pipeline is green:

13.1. Fetch unresolved discussions:

```
mcp__github__get_discussions(mr_iid: N)
```

13.2. If there are unresolved discussions from CI bots, resolve them
(reply + resolve). If there are human discussions, report them and
stop.

13.3. Merge:

```
mcp__github__merge_mr(mr_iid: N)
```

13.4. After merge, advance the Jira ticket status per
`./rules/jira/status_rules.md` (end-of-work transitions):

```
mcp__jira__transition_issue(issue_key: "[TICKET_KEY]", to_status: "[TARGET]")
```

13.5. **Workspace cleanup** per
`./rules/develop/pipeline_modes.md`. The branch is already
deleted by `merge_request.remove_source_branch`; clean any local
remnants:

- **Interactive / Guided:** `AskUserQuestion` — `Clean up workspace` /
  `Keep workspace`. If approved, delete.
- **Auto / Headless:** delete automatically.

```
rm -rf .workspace/[TICKET_KEY]/
```

Report: "Workspace cleaned up. Pipeline complete."
