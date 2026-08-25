---
last_reviewed: 2026-06-09
---

# GitHub MR pipeline polling

Skills that wait for a merge-request pipeline to reach a terminal state
follow this polling protocol. The protocol works in interactive,
guided, auto, and headless modes — each iteration is one MCP call plus
one foreground `sleep` that actually blocks until the next interval.

## Why this shape

- `mcp__github__get_mr` already returns `head_pipeline.status` as a
  structured field, so there's no JSON parsing, no `glab`/`jq` dependency,
  and no shell variable to clash with `status` (zsh's read-only builtin).
- Each poll is a discrete tool call, which gives clean compaction-recovery
  checkpoints between iterations.
- A **4:30 (270s) interval keeps the prompt cache warm** (Anthropic cache
  TTL is 5 minutes). Polls within the TTL pay the cached-input rate
  (~10× cheaper than fresh input). Going to 5+ minutes per poll drops
  out of cache and costs ~10× more per call.

## What NOT to use

- **`Bash(command: "sleep N", run_in_background: true)`** — works in
  interactive  Code (the harness's notification mechanism pauses
  the agent until the background bash completes), but **does not block
  in headless mode** (` -p`). The background bash returns
  immediately, the agent treats it as a normal tool-call completion,
  and the polling loop runs ~hundreds of times faster than intended.
- **`ScheduleWakeup`** — scoped to `/loop` dynamic mode; calling it
  from other skills mixes contracts.

## What to use — foreground bash with explicit timeout

Foreground `Bash` with an explicit `timeout` larger than the sleep
duration blocks the agent for the full interval in every mode. The
Bash tool's max timeout is 600,000ms (10 minutes), so any single sleep
up to 600 seconds works directly.

```
Bash(command: "sleep 270", timeout: 275000, description: "Wait 4:30 before next pipeline poll")
```

The `timeout` value should be slightly larger than the sleep so the
bash tool doesn't kill the sleep prematurely.

## Poll logic

Find the MR IID once, before the loop:

```
mcp__github__find_mr()
```

Then iterate. Each iteration checks **both** the pipeline status AND
new discussions:

1. Call `mcp__github__get_mr(mr_iid: N)` and read
   `head_pipeline.status`.
2. Call `mcp__github__get_discussions(mr_iid: N)` and diff against
   `last_known_discussions.latest_note_id` from `CONTEXT.md`.
3. **If new discussions exist**, handle per [Comment handling
   during polling](#comment-handling-during-polling) — typically
   fix-and-push immediately, which cancels the running pipeline and
   starts a new one. Then update `last_known_discussions` in
   `CONTEXT.md` and exit the polling loop (the new pipeline triggers a
   fresh poll cycle later).
4. **If no new discussions** and pipeline status is `running`,
   `pending`, or `created`:
   - Run `Bash(command: "sleep 270", timeout: 275000)`.
     This actually blocks for ~4:30 in every mode.
   - Return to step 1.
   - Do not poll faster than 270s — tighter intervals just burn tool
     calls without giving the pipeline time to make progress.
   - The caller (typically `/develop` Step 12) is responsible for
     bounding how many iterations are allowed (Monitor cap). When the
     cap is reached, stop polling and surface the current state.
5. **If status is `success`**: the MR object you already have carries
   `merge_status`, `head_pipeline.web_url`, and discussion state.
   Proceed to the caller's merge step.
6. **If status is `failed`, `canceled`, or `skipped`**: fetch ALL
   failing jobs and their logs (via `mcp__github__get_pipeline_jobs`
   + `mcp__github__get_job_log`) before handing off to the caller's
   failure-handling path. Pass the **complete list** of failures to
   the fix pipeline — don't fix one job and push, then discover
   another. RSpec failures especially benefit from consolidated
   fixes because the suite runs ~20 minutes; one extra unnecessary
   push restarts the full suite.

## Comment handling during polling

When a new discussion appears mid-pipeline, the agent responds based
on the comment's source. Source identification follows
[`github.md`](github.md) §Comment source identification.

| Source | Behavior |
|---|---|
| ** Code Review** (`` reviewer bot, severity-emoji body) | Fix immediately, push, exit polling. The new pipeline cancels the current one — saves the rest of CI runtime. |
| **Static Analysis / Pronto bot** (`project_14_bot_*`, `[Static Analysis]` marker) | Fix immediately, push, exit polling. Same rationale — push cancels current pipeline. |
| **Human reviewer** (any other non-system username) | Fix immediately if the comment is actionable. If unclear or contested, escalate per the mode-specific `NEEDS_DECISION` flow rather than guessing. |
| **System notes** (`.system: true`) | Skip — auto-generated metadata (merge status, label changes). |

**Why "fix immediately" works**: GitHub's pipeline-cancel-on-new-push
behavior means each push wipes the running pipeline and starts a fresh
one. Addressing one comment + pushing is better than waiting for the
current pipeline to complete and then fixing — you save the ~17 min
of unnecessary post-push CI time.

**Why this differs from RSpec failures** (handled in step 6 above):
RSpec failures are pipeline *job failures*, not discussions. Multiple
RSpec splits can fail in the same run. Fix them in one consolidated
push (when the pipeline reaches terminal state with `failed`) rather
than push-once-per-failure, which would re-run a 20-minute suite for
each fix.

**State tracking**: after handling a new discussion, update
`CONTEXT.md`'s `last_known_discussions.latest_note_id` to the
highest-seen note ID so the next poll cycle (or `--resume`) doesn't
re-process it.

## Longer intervals than 10 minutes

If a caller needs an interval >10 minutes (the Bash tool max), chain
sleeps in sequence:

```
Bash(command: "sleep 600 && sleep 600", timeout: 1205000)
```

Each chained `sleep N` runs to completion within the parent bash; only
one tool call is issued. The 2-second buffer in `timeout` is so the
bash tool doesn't kill the chain prematurely.

This is rarely needed for pipeline polling but is documented for
completeness.

## Mode behavior

- **Auto / headless:** poll up to the Monitor cap (see below).
- **Interactive / guided:** use `AskUserQuestion` with options
  `Check now` / `Done for now`.
  - `Check now`: run one poll iteration, report, ask again if still
    running.
  - `Done for now`: report MR URL and stop.

## Monitor cap

Polling must be bounded. Without a cap, a hung CI pipeline, a missed
state transition, or a GitHub outage would let the loop run forever.

**Default cap: 4 iterations** (~18 minutes at the 4:30 interval —
enough to clear typical pipeline checkpoints like CCR + Pronto + the
start of RSpec).

### Caller behavior

- Track iteration count from the first poll of the current polling
  cycle.
- After each poll, increment the counter.
- If the counter reaches the cap and the pipeline status is still
  `running`, `pending`, or `created`: stop polling.
- On cap-hit:
  1. Write `[workspace]/state/blocker.md` summarizing where the
     monitor stopped (MR URL, current pipeline status, iteration
     count, time elapsed since first poll).
  2. Post a Jira comment with the same summary so the team knows the
     work is parked.
  3. Exit cleanly. The user can re-launch the skill (or `--resume`)
     to resume polling.

### Cap reset on re-entry

If polling is interrupted by a fix cycle (comments addressed, test
failures fixed, push made, pipeline restarted), the **cap counter
starts fresh** on the next entry to the polling loop. Each entry to
`Monitor Pipeline` gets its own budget.

### Overriding the default

The cap is the default; users can override it via natural-language
prompt direction parsed by the orchestrator in Phase 0. Examples:

- `/develop MDP-12345 monitor up to 10 polls`
- `/develop MDP-12345 watch pipeline for 30 minutes`
- `/develop MDP-12345 no monitor cap` (orchestrator should treat this
  as a high but finite cap, not infinity — e.g., 30 polls / ~2.25 hr)

If the prompt doesn't mention monitoring, use the default of 4.

## Related

- [`github.md`](github.md) — GitHub MCP tool reference (full tool list and
  comment-source identification).
- [`../agent_authoring/compaction_recovery.md`](../agent_authoring/compaction_recovery.md)
  — recovery pattern between poll iterations.
