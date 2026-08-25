# Step 11: Commit

**Runs in orchestrator context** (not a subagent).

The single interactive/guided commit gate is 11.3 (Commit & push). Auto and
headless commit and push without pausing.

11.1. `git status` and `git diff --stat`.

11.2. Compose the commit message per
`./rules/git/commit_trailer.md`:

```
[TICKET_KEY] Brief description

What changed and why.

Co-Authored-By: [your model name] <noreply@anthropic.com>
```

11.3. **Commit & push gate.**
- **Interactive / Guided:** present the commit message and a `git diff --stat`
  summary (guided: add a short recap of the work done in Steps 2–10), in the
  collaborative voice from `./rules/develop/interactive_ux.md`. Name what
  — if anything — will be recorded in Jira as documentation (per the status
  rule in `./rules/develop/pipeline_modes.md`). Then `AskUserQuestion`:
  `Commit and push` / `I'll review the diff first` / `Commit only (no push)`.
  - `I'll review the diff first`: stop; remind the user of
    `git diff origin/develop..HEAD` and to resume with `/develop [TICKET_KEY]`
    when ready.
  - `Commit only (no push)`: commit, then skip 11.5–11.7 and run 11.8.
- **Auto / Headless:** commit and push without asking.

**If `ticket_type` is `local`: commit and stop.** Do not push, create
MRs, or update Jira. Skip 11.4–11.7, run 11.8
(`.-touched-files` cleanup per
`./rules/agent_authoring/touched_files.md`), skip 11.9–11.10 and
Steps 12–13. Report: "Committed locally on [branch]."

11.4. **In `headless` mode only** — workspace lifecycle per
`./rules/develop/headless_escalation.md`. Force-commit the
workspace, then remove it, in two consecutive commits before the MR
push:

```
git add -f .workspace/[TICKET_KEY]/
git commit -m "[TICKET_KEY] Preserve workspace for resume"
git rm -rf .workspace/[TICKET_KEY]/
git commit -m "[TICKET_KEY] Remove workspace from final state"
```

Skip in `interactive`, `guided`, and `auto` modes.

11.5. Push and create the MR:

```
git push -u origin [branch] \
  -o merge_request.create \
  -o merge_request.target=develop \
  -o merge_request.remove_source_branch
```

11.6. Report the MR link. This is a **status update** — route it per "Status
updates vs. documentation" in `./rules/develop/pipeline_modes.md`:

- **Interactive / Guided:** report the MR URL in chat. Do NOT post it to Jira.
- **Auto / Headless:** post it to Jira:

```
mcp__jira__add_comment(issue_key: "[TICKET_KEY]", body: "MR created: [MR_URL]")
```

11.7. **Story tickets only — skip for Bug/Spike/Task.** If the Story has a
parent Feature AND the work produced Feature-level **documentation** — an
under-specified requirement resolved, an addition beyond spec, or a design
decision later stories depend on — post that as a comment on the **parent
Feature**. This is documentation, posted in **every mode**.

- Do NOT post a pure status note (e.g., "Story complete", or just the MR
  link). If the work had no Feature-level decisions to record, **skip this
  step**.
- Bug tickets have their own root-cause documentation on the Bug itself (see
  General rules); Spike/Task tickets aren't part of an active Feature flow.

```
mcp__jira__add_comment(issue_key: "[PARENT_FEATURE_KEY]", body: "[the implementation decisions/deviations; end with the AI co-author trailer per ./rules/git/commit_trailer.md]")
```

11.8. **Clean up `.-touched-files`** per
`./rules/agent_authoring/touched_files.md` (post-commit cleanup
section).

11.9. **Update Acceptance Criteria** if the ticket has AC populated:

11.9.1. Re-fetch the ticket to get the structured AC list with
`local_id`s:

```
mcp__jira__get_issue(issue_key: "[TICKET_KEY]")
```

Use the `acceptance_criteria` array from the response — each item has
`text`, `done`, and `local_id`.

11.9.2. For each item satisfied by the work done, set `done: true`.

11.9.3. Only check off items you can verify were addressed (code
exists, tests pass).

11.9.4. Update via `mcp__jira__update_acceptance_criteria`:

```
mcp__jira__update_acceptance_criteria(issue_key: "[TICKET_KEY]", items: [full list with updated done fields])
```

Pass the complete list — `local_id` values are required for correct
write-back.

11.9.5. If ALL items are now done: in `auto` / `headless`, note it in the
11.6 MR comment; in `interactive` / `guided`, mention it in chat.

11.10. Do NOT advance ticket status yet — that happens after merge
(Step 13).
