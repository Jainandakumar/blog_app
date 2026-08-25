# Fix Step 1: Read Feedback

**Runs in orchestrator context.**

1.1. If MR IID was provided in your context, use it directly — skip
discovery. Otherwise, find the MR:

```
mcp__github__find_mr()
```

**If result is null** (no open MR for the current branch), ask the
user: "No open MR found for the current branch. Provide the MR URL
or ticket key to search:"

Parse the response:

- **MR URL** (contains `/merge_requests/`): extract the IID from the
  URL path (e.g., `.../merge_requests/1234` → IID `1234`).
- **Ticket key** (e.g., `MDP-123456`):
  ```
  mcp__github__find_mr(search: "MDP-123456")
  ```
  If still null: "No open MR found for ticket MDP-123456. Verify the
  MR exists and is open."

Either way, fetch full MR details:

```
mcp__github__get_mr(mr_iid: N)
```

1.2. Check `head_pipeline.status`:

- `running` / `pending`: report to user, wait.
- `success`: skip to Step 7 (Resolve Discussions).
- `failed`: continue.

1.3. Fetch unresolved discussions:

```
mcp__github__get_discussions(mr_iid: N)
```

1.4. Fetch failed jobs + logs:

```
mcp__github__get_pipeline_jobs(pipeline_id: N, scope: "failed")
```

For each failed job, write the log to a workspace file (keeps large
logs out of orchestrator context):

```
mcp__github__get_job_log(job_id: N)
```

Write `result.log` to `[workspace]/job_{JOB_ID}_log.txt`. Extract a
brief failure summary for categorization from the last 20 lines of
that file.

1.5. Categorize: code review comments, test failures, warnings,
build/lint errors. Reference `[workspace]/job_*_log.txt` for full
failure details.

1.6. Present categorized feedback before proceeding.

## Pipeline failure ownership

A failing pipeline blocks merge. Investigate even if the failure looks
unrelated.

1.7. Identify failing spec(s) from job log.

1.8. Run locally: `bundle exec rspec spec/path/to/failing_spec.rb`.

- **Passes locally:** likely flaky — retry the job, don't push empty
  commit.
- **Fails locally:** rebase first
  (`git fetch origin develop && git rebase origin/develop`), retry.
- **Still fails after rebase:** fix it or report with evidence.
