# ` -p` Headless Invocation Reference

How to run this project's `./` skills unattended via ` -p`
(headless / SDK CLI mode). Covers flag selection, mode detection, where
artifacts land, and the `--resume` workflow.

For the design contract behind headless mode (modes, escalation, workspace
lifecycle), see [`./rules/develop/pipeline_modes.md`](rules/develop/pipeline_modes.md).
For the original portable checklist, see
[`./headless/headless-readiness.md`](headless/headless-readiness.md).

---

## When to use ` -p`

Use ` -p` (headless mode) when:

- Running a skill from cron, CI, a queue worker, or a watcher daemon.
- Driving multiple parallel sessions where no human can attend each one.
- Re-running a session via `--resume` from an external orchestrator.

Use interactive  Code (no `-p`) when:

- A developer is at the keyboard.
- The task requires real-time decisions or judgment calls.
- Setup, credential entry, or environment configuration is needed
  (`/setup` is interactive-by-design).

---

## Canonical invocation

```bash
 -p "/develop MDP-NNNNNN headless" \
  --append-system-prompt-file ./headless/autonomy-preamble.txt \
  --permission-mode acceptEdits \
  --output-format stream-json \
  | tee .workspace/_runtime/run-$(date +%Y%m%d-%H%M%S)-$$.jsonl
```

### Flag-by-flag

| Flag | Why we use it |
|---|---|
| `-p "<prompt>"` | Invokes  Code in SDK / headless mode. Sets `_CODE_ENTRYPOINT=sdk-cli`, which the orchestrator skills detect to auto-elevate to `headless` mode. |
| `--append-system-prompt-file ./headless/autonomy-preamble.txt` | Appends the autonomy preamble to the existing system prompt. **Critical**: do NOT use `--system-prompt` — that *replaces* the default system prompt and loses all project context (.md, universal rules, skill knowledge). |
| `--permission-mode acceptEdits` | Auto-accepts Edit and Write tool calls during the run. Requires that `permissions.allow` in `./settings.json` lists every Bash, Edit, Write, and `mcp__*` pattern the skill will use — otherwise permission prompts still fire and the run blocks. See [§Permission setup](#permission-setup). |
| `--output-format stream-json` | Emits one JSON event per line (turn-by-turn) instead of buffering the whole run. **Use this, not `--output-format json`** — the buffered form writes nothing to disk until the process exits, which means you can't read `session_id`, monitor progress, or intervene during a long run. With stream-json + `tee`, the `.jsonl` file populates live and you can grep/jq the session_id within seconds of launch. |

### Flags we deliberately do NOT use

| Flag | Why we skip it |
|---|---|
| `--system-prompt` | Replaces (does not append). Loses project context. Always use `--append-system-prompt-file`. |
| `--dangerously-skip-permissions` | Bypasses every tool-call check. We rely on `permissions.allow` + `acceptEdits` for security observability. |
| `--bare` | Strips the system prompt entirely. Loses all skill knowledge. |

### Including the prompt keyword

The skill's Phase 0 detects headless mode via either:

1. `_CODE_ENTRYPOINT=sdk-cli` (set automatically by ` -p`), OR
2. A keyword in the prompt: `headless`, `unattended`, or `non-interactive`.

Both signals work; the keyword is belt-and-suspenders for cases where the
env var is unreliable. For predictability, include the keyword in the
prompt: `/develop MDP-NNNNNN headless`.

To run a skill in `auto` mode (no interaction, but user is watching) under
a regular `` session, use `/develop MDP-NNNNNN auto` — no `-p` flag,
no preamble file.

---

## Permission setup

`permissions.allow` in `./settings.json` must cover every Bash
command, Edit/Write path, and `mcp__*` tool the skill will use in
headless mode. Gaps surface as permission prompts mid-run, which halt
the pipeline since there's no user to click Allow.

The first headless attempt is expected to surface gaps. Iterate:

1. Run with current `permissions.allow`.
2. If a permission prompt fires (visible in the JSON output as a halt
   reason), add the missing pattern to `permissions.allow`.
3. Re-run.

Anchored matchers prevent substring collisions — e.g., `^(Edit|Write|
Bash|mcp__.*)$` does not match `TodoWrite` (which contains `Write` as a
substring).

If you need observability data on what tools sessions actually use
(to build the allow list systematically), enable a PreToolUse logging
hook in `./settings.json` temporarily. Removed from default
project config to keep dev-machine overhead at zero.

---

## Where artifacts land

| Artifact | Path |
|---|---|
| Per-skill workspace | `.workspace/{ticket}/` |
| Cross-skill shared context | `.workspace/{ticket}/CONTEXT.md` |
| Mode and step progress (per skill) | `.workspace/{ticket}/STATE_<skill>.md` |
| Session ID for `--resume` | `.workspace/{ticket}/state/session` |
| Escalation payload (Tier 2) | `.workspace/{ticket}/state/escalation.json` |
| Blocker report (Tier 3) | `.workspace/{ticket}/state/blocker.md` |
| Teams reply (when watcher writes one) | `.workspace/{ticket}/state/teams-reply.md` |

`.workspace/*` is gitignored. The workspace is only committed to a
branch under the documented [workspace lifecycle](rules/develop/pipeline_modes.md)
(blocker preservation or pre-MR snapshot).

---

## `--resume` workflow

```bash
# tail -1 selects the most-recent run's session_id. The glob expands in
# lexicographic order which is chronological because filenames carry a
# YYYYMMDD-HHMMSS timestamp; jq emits session_ids file-by-file, so the
# last line is from the newest file.
SESSION_ID=$(jq -r 'select(.session_id != null) | .session_id' \
  .workspace/_runtime/run-*.jsonl | tail -1)

 -p "Continue MDP-NNNNNN." \
  --resume "$SESSION_ID" \
  --append-system-prompt-file ./headless/autonomy-preamble.txt \
  --permission-mode acceptEdits \
  --output-format stream-json \
  | tee -a .workspace/_runtime/run-$(date +%Y%m%d-%H%M%S)-$$.jsonl
```

### Caveats

- **Transcripts are local.** `--resume` works only on the same host + cwd
  where the original session ran. Sessions are not portable between
  machines.
- **Working tree state matters.** If the previous session removed the
  workspace folder as part of the MR-creation lifecycle, the first action
  of the resumed agent is `git checkout HEAD~1 -- .workspace/{ticket}/`
  to recover it.
- **Ticket-comment check is mandatory.** Every resume's first action is
  to fetch ticket comments via `mcp__jira__get_issue` and diff against
  the `last_known_comments` field in `CONTEXT.md`. A comment added between
  sessions may change what needs to happen next.

---

## Production hardening checklist

Before running headless against production tickets:

- [ ] Dedicated bot identity for git commits (`user.email` set; commits
      not attributed to a personal account).
- [ ] Credentials in a secrets manager (not on-disk plaintext). MCP
      tools handle their own auth; bot CLI tools (github, jira)
      read from env vars populated by the secrets layer.
- [ ] Branch protection rules enforced on `master`, `develop`, release
      branches. The autonomy preamble forbids force-push and direct
      pushes to protected branches — branch protection is the
      defense-in-depth.
- [ ] CODEOWNERS configured so headless-created MRs require human
      review before merge.
- [ ] Allowlist (`permissions.allow`) reviewed and tightened from
      `acceptEdits` toward `dontAsk` for the production runner.
- [ ] External watcher daemon configured to consume `state/escalation.json`
      and drive resumes. (Currently future infrastructure — without it,
      headless runs stop at Tier 2.)

---

## Related

- [`./rules/develop/pipeline_modes.md`](rules/develop/pipeline_modes.md) — mode taxonomy, escalation contract, workspace lifecycle
- [`./headless/autonomy-preamble.txt`](headless/autonomy-preamble.txt) — the file `--append-system-prompt-file` consumes
- [`./headless/headless-readiness.md`](headless/headless-readiness.md) — original portable checklist with per-line deviation notes
- [`./rules/meta/decision_log.md`](rules/meta/decision_log.md) — entries dated 2026-05-27 covering all headless deviations
