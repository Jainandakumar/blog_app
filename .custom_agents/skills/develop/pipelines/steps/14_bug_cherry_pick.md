# Step 14: Bug-specific Cherry-pick to Release and Master

**Runs only for Bug tickets, after Step 13 (Merge). Skip for all other
ticket types.**

The develop-branch MR has already been merged. Cherry-pick the bug fix
commit(s) to the release and master branches so they receive the fix
without waiting for the next regular deployment.

## 14.1 Ask for the release branch name

Ask the user: "What is the current release branch name?" There is no
programmatic way to identify it today.

## 14.2 Cherry-pick to the release branch

```bash
git fetch origin
git checkout -b MDP-NNNNNN_cherry_pick_release origin/[RELEASE_BRANCH]
git cherry-pick [COMMIT_HASH(ES)]
git push -u origin MDP-NNNNNN_cherry_pick_release \
  -o merge_request.create \
  -o merge_request.target=[RELEASE_BRANCH] \
  -o merge_request.remove_source_branch
```

Capture the MR URL from the push output (or call
`mcp__github__find_mr(branch: "MDP-NNNNNN_cherry_pick_release")`).

**On cherry-pick conflicts:** Report to the user and stop. Do not
force-resolve conflicts on release or master — the user resolves
manually.

## 14.3 Cherry-pick to master

```bash
git checkout -b MDP-NNNNNN_cherry_pick_master origin/master
git cherry-pick [COMMIT_HASH(ES)]
git push -u origin MDP-NNNNNN_cherry_pick_master \
  -o merge_request.create \
  -o merge_request.target=master \
  -o merge_request.remove_source_branch
```

Capture the MR URL.

**On cherry-pick conflicts:** Report and stop, same as 14.2.

## 14.4 Monitor cherry-pick pipelines

Both cherry-pick branches run their own CI pipelines. The release and
master branches may have diverged from develop, so failures here are
independent of the develop pipeline and require manual investigation.

Discover each cherry-pick MR IID:

```
mcp__github__find_mr(branch: "MDP-NNNNNN_cherry_pick_release")
mcp__github__find_mr(branch: "MDP-NNNNNN_cherry_pick_master")
```

Polling follows `./rules/integrations/github_pipeline_polling.md`,
including the Monitor cap (default 4 iterations; reset on entry to
this step). If the cap is reached with either pipeline still running,
report the current state and proceed to 14.5 — cherry-pick pipelines
diverging from develop is a known case for human resolution.

- **Both green:** proceed to 14.5.
- **Either failed:** report failures. Divergence from develop is common
  for cherry-pick pipelines — the user investigates and resolves.
  Proceed to 14.5 regardless (MR links are still valid and Jira fields
  should still be updated).

**Interactive/guided:** use `AskUserQuestion`
`Check pipeline now` / `Done for now`. "Done for now" reports both MR
URLs and stops — the user monitors manually.

Merging cherry-pick MRs requires Hot Patch approval (a manual process
outside this pipeline). The poll here surfaces divergence failures
early.

## 14.5 Populate Bug-specific fields

Fetch the current Bug field values first:

```
mcp__jira__get_issue(issue_key: "[TICKET_KEY]")
```

Check the `bug_fields` object in the response.

For each field:

- **Already populated correctly:** skip (don't overwrite).
- **Empty or incorrect:** populate/update.

| Field | Source |
|-------|--------|
| `link_to_rc_mr` | MR URL from 13.2 |
| `link_to_main_mr` | MR URL from 13.3 |
| `reason_for_request` | Ask user if empty (plain text or markdown, 1-2 sentences) |
| `how_big` | Ask user if empty (1 sentence describing impact) |
| `how_many_clients` | Ask user if empty (`all` or specific list) |
| `workaround` | Ask user if empty (`YES`/`NO` + sentence if yes) |
| `risk_of_doing` | Ask user if empty (1-3 sentences) |
| `risk_of_not_doing` | Ask user if empty (1-3 sentences) |

**Interactive/guided:** present empty fields, collect answers, then
update.
**Auto:** update MR links automatically; for other empty fields, make a
reasonable assessment from the ticket description and the Step 11.5 root
cause comment, then update and note what was auto-populated.

Update only the fields that need changes:

```
mcp__jira__update_bug_fields(issue_key: "[TICKET_KEY]", fields: { link_to_rc_mr: "...", ... })
```

Pass only the fields that need updating — omitted fields are not
changed.
