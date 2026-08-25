# Headless-Readiness Checklist for `./` Setups
A portable checklist for taking an existing  Code project (skills + agents + rules + MCP servers) and making it work end-to-end via ` -p` (headless / unattended) execution.
Audience: someone who already has a working interactive `./` setup and wants to run the same skills from cron, CI, a queue worker, or a watcher script — with **no human at the keyboard**.
Assumes the project uses one or more MCP servers (Jira, GitHub, Teams, custom). Assumes `git` and `jq` are installed. Forge operations (MR creation, merge, comments) go through GitHub MCP tools (`mcp__github__*`) where available, with `git push -o merge_request.create=true` as the canonical creation path.
---
## 1. Critical — without these, ` -p` won't complete a task
### 1.1 Eliminate hardcoded machine paths
- [ ] `grep -rn "/Users/\|/home/\|/Users\|C:\\\\" ./` returns nothing operational. Documentation strings flagging "don't use hardcoded paths" are fine; actual paths are not.
- [ ] Replace with `$(git rev-parse --show-toplevel)` (for the project root) or workspace-relative paths (`././...`).
### 1.2 Mode detection in every orchestrator skill
- [ ] Phase 0 of each orchestrator skill scans `$ARGUMENTS` and the initial prompt for the keywords `auto`, `run unattended`, `non-interactive`, `headless`.
- [ ] If any match → `MODE = auto`; otherwise `MODE = interactive`.
- [ ] `MODE` is recorded once in the workspace state (e.g. `orchestrator_state.md` line `## Mode: auto`) so every later phase reads it without re-inferring.
### 1.3 Guard every user-wait step on mode
- [ ] Any phase that would `AskUserQuestion` / wait for human input is wrapped in a mode check. - **auto mode**: skip the wait, choose a sensible default, or proceed to the next phase. - **interactive mode**: behave as before.
- [ ] Skills that fundamentally need a human (e.g. requirements gathering) declare themselves **interactive-only** at the top of the SKILL file and refuse to run otherwise.
### 1.4 Pre-approve every tool call in `settings.json`
- [ ] `permissions.allow` contains every `Bash(command:*)` the skill might invoke. Common ones: `git add`, `git commit`, `git push`, `git rev-parse`, `bundle exec rubocop`, `bundle exec rspec`, `jq`, `curl`, and any workspace-cleanup commands.
- [ ] `Edit(path/*)` and `Write(path/*)` patterns cover every source-tree directory the skill modifies (`app/`, `config/`, `db/`, `engines/`, `lib/`, `spec/`, `test/`, etc.).
- [ ] Every MCP tool name the skill uses is in the allow list verbatim (`mcp__jira__get_issue`, `mcp__github__merge_mr`, etc. — see `./rules/integrations/` for the canonical tool lists).
- [ ] **Important: anchor regex patterns** for hook matchers (`^(Edit|Write|Bash|mcp__.*)$`) — unanchored `Write` will match `TodoWrite` as a substring.
- [ ] **Build the allow list from observation when possible.** A PreToolUse logging hook (§4) is the structured approach but is not in this project's default settings.json — enable temporarily if needed. Without it, derive the list by iterating: run, hit a prompt, add the pattern, re-run.
### 1.5 Make every external-service call conditional
- [ ] Every Teams post, email send, webhook call, etc. is guarded by an "if-available" check: - "If the Teams MCP tool is exposed, call it; otherwise write `state/escalation.json` and let an external watcher route it." - "If `mcp__plugin_x__y` tool is available, call it; otherwise skip."
- [ ] A failed/unavailable external service must not block the core task.
- [ ] **For this project**: `/setup verify` is the gate. Tools are guaranteed available because `/setup` ran first; skills do not branch on tool absence. If `/setup verify` fails in headless mode, that is itself a blocker.
### 1.6 Gitignore secrets and per-machine state
- [ ] `/./settings.local.json` is gitignored (holds per-developer tokens).
- [ ] Documented expectation: developers populate `settings.local.json` themselves; never committed.
- [ ] **For this project**: also gitignored — `/./*.json` (with `!./settings.json` allowlist), `/./rules/LOCAL.md`, `/./projects/`, `/.workspace/*` (with README/.gitkeep allowlist). See `.gitignore` for the canonical list.
---
## 2. Strongly recommended — make headless runs resumable and debuggable
### 2.1 Unified workspace conventions
- [ ] Every orchestrator skill writes to `.workspace/{workspace_id}/` (flat path, no skill-specific subdirs).
- [ ] `workspace_id` priority: ticket key (`MDP-123456`) → slugified prompt fallback.
- [ ] `workspace_id` settled **before any subagent launches**; passed to every subagent in its prompt.
- [ ] `.workspace/*` is gitignored, but `.workspace/README.md` is exempted so the directory is tracked.
- [ ] When a headless run can't complete, the agent force-adds and commits its workspace: `git add -f .workspace/{id}/ && git commit && git push` — so the branch carries enough state for a follow-up session (any host) to resume.
- [ ] **Workspace lifecycle (headless mode, develop skill)**: before the final push that creates the MR, force-commit `.workspace/{id}/` and then `git rm -rf` it in a follow-up commit. The workspace lives in branch history (recoverable via `git checkout HEAD~1 -- .workspace/{id}/` on `--resume`) but never enters main.
- [ ] Cleanup on successful completion: `/planning` cleans up after all tickets created; `/develop` cleans up after MR merged. Interactive mode prompts via `AskUserQuestion`; auto/headless modes clean automatically.
- [ ] **Path deviation from the original checklist**: this project uses `.workspace/` (not `./workspace/`). The location is outside `./` because  Code's hardcoded sensitivity gate intercepts writes to any `./` subpath even with explicit allow rules — see `./rules/meta/decision_log.md` entry "2026-05-28 — Workspace path moves from `./tasks/` to `.workspace/`" for the empirical evidence.
### 2.2 Autonomy preamble file
Loaded via `--append-system-prompt-file` (NOT `--system-prompt`, which replaces the default and loses project context):
- [ ] `./headless/autonomy-preamble.txt` contains: - "You are running autonomously with no human watching" framing - Decision-making rule: make reasonable choices, never pause for confirmation - Blocker protocol: write structured `state/blocker.md`, write `state/escalation.json` for the external watcher to post to Teams, force-add + commit workspace, push, exit - Safety rules: no force-push, no branch deletes, no master pushes, no workspace deletion outside the documented lifecycle - Completion behavior: push branch with `-o merge_request.create=true` (GitHub push options); MR merge handled via `mcp__github__merge_mr`
### 2.3 Headless invocation reference doc
- [ ] `./usage.md` (or similar) covers: - Full ` -p` invocation with every flag explained — and every flag deliberately skipped (`--bare`, `--dangerously-skip-permissions`) - Where artifacts and session IDs land (`.workspace/{id}/CONTEXT.md`, `.workspace/{id}/STATE_<skill>.md`, `state/session`) - `--resume` pattern with host/cwd pinning caveat (transcripts are local to the cwd + machine), and the requirement that every `--resume` first fetches ticket comments via MCP to surface changes since the last session - Production hardening checklist (dedicated bot identity, secrets manager, branch protection, etc.)
### 2.4 MR creation and merge — no forge scripts needed
- [ ] **MR creation**: use `git push -o merge_request.create=true` (GitHub push options). Atomic with the push; no extra CLI invocation; no token handling in the skill layer. Title and target branch are conveyed via additional `-o merge_request.<...>` options. See `./rules/workflows/merge_requests.md` for the canonical form.
- [ ] **MR merge**: use `mcp__github__merge_mr` (existing MCP tool). Always removes the source branch.
- [ ] **MR comments / discussion**: use `mcp__github__create_note`, `reply_to_discussion`, `resolve_discussion` (existing MCP tools). See `./rules/integrations/github.md`.
- [ ] **No `./scripts/` folder needed for forge work.** Push options + MCP cover the surface area. See decision-log entry "2026-05-27 — MR creation/merge uses git push options + MCP".
- [ ] **Exception, future**: if a Teams notification mechanism arrives that  from a script wrapper (e.g. multi-line webhook with retries), it can be added at that point. Not in scope for the initial headless-readiness pass.
---
## 3. Per-file conventions (apply across all skills, agents, rules)
- [ ] **200-line limit per `./` config file.** Anything longer gets extracted into a `./rules/{name}.md` file and referenced via "Read `./rules/{name}.md` before proceeding."
- [ ] **Naming**: skill folders use lowercase-hyphen (`code-review/`); agent files, rule folders, and rule files use snake_case (`code_review_fix.md`, `agent_authoring/critical_constraints.md`). No spaces. **Deviation from the original checklist's kebab-case-everywhere**: see decision-log entry "2026-05-27 — Snake_case naming preserved for agents/rules". Established project convention; aligns with `./rules/meta/instruction_authoring.md` §6.
- [ ] **Frontmatter completeness** on agents: `name`, `description` (specific enough for an orchestrator to choose this agent), `model`, `tools` (restricted to what the agent actually needs).
- [ ] **Cross-references** use relative paths (`./rules/foo.md`), not absolute or HTTP.
---
## 4. Permission observability (opt-in for investigation)
- [ ] **For this project**: a PreToolUse logging hook is **not** in the default `./settings.json`. Fleet-wide observability without consumers wasn't worth the noise. The hook can be enabled temporarily when you need to (a) explain why a headless job failed, or (b) collect the actual tool surface to build `permissions.allow` systematically.
- [ ] When enabled: anchored matcher `^(Edit|Write|Bash|mcp__.*)$`, inline bash command that reads tool-call JSON from stdin, appends to a chosen log file, exits 0 with no JSON output. Zero token cost (OS subprocess). Pattern: anchor matchers; remove the hook after the investigation completes.
- [ ] Before tightening from `acceptEdits` to `dontAsk` for production, run the iteration loop in §1.4 — or enable the hook temporarily to capture a complete tool inventory.
---
## 5. Optional — escalation and feedback loops
- [ ] **Three-tier escalation** (headless mode only): see `./rules/develop/pipeline_modes.md` for the canonical contract. Tier 1 = orchestrator resolves from context. Tier 2 = write `state/escalation.json`, stop, wait timer (default 30 min). Tier 3 = on resume-after-timeout, force-commit workspace, push, update ticket, write `state/blocker.md`, exit. `auto` mode stops at Tier 1 (no user-facing escalation; user is watching locally). `interactive` and `guided` modes don't escalate — they ask the user inline.
- [ ] **Human-in-the-loop escalation to Teams**: external watcher polls `state/escalation.json`, posts to Teams, waits for reply or timeout. Stages reply into `state/teams-reply.md` for the next `--resume` to consume. Use a threading primitive (Teams message reply) for concurrency across multiple simultaneous agents. **In scope: the contract (state files, behavior on resume).** Out of scope this branch: the watcher daemon itself and the Teams plumbing.
- [ ] **CI / pipeline monitor**: a loop that reads pipeline failures, asks the agent to fix, pushes, and watches for re-triggered runs. Threading model: each MR is its own loop instance.
- [ ] **Resume-on-comment**: a watcher that detects Jira comments and GitHub MR comments on the agent's open MRs and routes them back into a `--resume` of the original session. Every `--resume` checks for new ticket comments as its first action (canonical in `pipeline_modes.md`).
---
## 6. Validation pass — minimum smoke test before declaring done
After applying everything above, run this end-to-end:
- [ ] ` -p "/develop {minimal ticket} headless" --append-system-prompt-file ./headless/autonomy-preamble.txt --permission-mode acceptEdits --output-format json > .workspace/smoke/run.json`
- [ ] Verify `jq -r '.session_id' .workspace/smoke/run.json` produces a UUID
- [ ] Verify the run completed (or stopped on a real blocker, NOT on a permission prompt)
- [ ] Verify any user-wait phases were skipped or auto-resolved (mode persisted to `STATE_<skill>.md`; `_CODE_ENTRYPOINT=sdk-cli` auto-elevated to headless mode)
- [ ] Verify external services either fired (if tools present) or wrote `state/escalation.json` for the watcher
- [ ] If the run stopped on a blocker, verify the workspace was force-added + committed + pushed and `state/blocker.md` was written
- [ ] Run ` -p "Continue {workspace_id}." --resume "$(cat .workspace/{workspace_id}/state/session)" ...` and verify the agent (a) fetches new ticket comments first and (b) picks up correctly