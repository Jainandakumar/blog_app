# Skills & Agents Architecture

**Purpose:** Reference doc for maintaining the skill/agent system. No skill or agent
reads this file. Only read this when working on skill/agent updates.

---

## How Skills Work

When a user types `/skill-name`,  Code's Skill tool expands the SKILL.md file
directly into the **main conversation context**. Everything in SKILL.md becomes part
of the current prompt. There is no automatic subagent — unless the skill explicitly
launches one via the Agent tool.

### Context implications

- SKILL.md content persists in the main conversation for the rest of the session
- Large SKILL.md files consume context that can't be recovered (even `/compact` may
  not fully reclaim it since the skill content is part of the prompt structure)
- If a skill does heavy work (reading many files, running many commands) in the main
  context, that work also consumes main context permanently

### The launcher pattern (adopted March 2025)

To protect the main conversation from context exhaustion:

1. **SKILL.md is a thin launcher** (~30-80 lines) that parses arguments and launches
   a single orchestrator agent
2. **The orchestrator agent** reads detailed instruction files and coordinates subagents
3. **Subagents** do the actual work (code, test, review, etc.)
4. **Main conversation** only holds: the launcher prompt + the orchestrator's final summary

This means if the orchestrator or any subagent fills its context, the main conversation
is unaffected. The user gets back either a result or an error — not a destroyed session.

### Skills using the launcher pattern

| Skill | Launcher | Orchestrator reads |
|-------|----------|-------------------|
| `/develop` | `skills/develop/SKILL.md` | `skills/develop/pipelines/*.md` |
| `/code-review` | `skills/code-review/SKILL.md` | `skills/code-review/orchestrator_instructions.md` (branch-review), `skills/code-review/feature_review_instructions.md` (Feature-level review) |
| `/planning` | `skills/planning/SKILL.md` | `skills/planning/planning_instructions.md` |

### Skills NOT using the launcher pattern

| Skill | Lines | Notes |
|-------|-------|-------|
| `/jira` | 317 | Mostly API calls, moderate context. OK for now. |
| `/github` | 196 | Small, fine as-is. |
| `/setup` | 316 | One-time use, fine as-is. |

---

## How Agents Work

Agent instruction files (`./agents/*.md`) are read BY subagents, not loaded
into the main context. A subagent is told "Read `./agents/code_business_logic.md`"
(or another code agent) and it reads the file in its own context.

### Agent files

| File | Used by | Purpose |
|------|---------|---------|
| `plan.md` | develop step 4 (Plan) | Break requirements into tasks |
| `research.md` | develop step 5 (Research) | Explore codebase for patterns |
| `architecture.md` | develop step 6 (Architecture) | Create class skeletons |
| `design.md` | develop step 7 (Design) | Add method signatures |
| `plan_summary.md` | develop Plan Review gate (interactive only) | Summarize plan + skeletons for pre-code user review |
| `code_business_logic.md` | develop step 8 / fix step 3 (when files match `app/models/**`, `app/validators/**`) | Implement business logic |
| `code_api.md` | develop step 8 / fix step 3 (when files match `app/controllers/**`, `engines/api/app/controllers/**`, `app/serializers/**`) | Implement controller actions and API endpoints |
| `code_ui.md` | develop step 8 / fix step 3 (when files match `app/views/**`, `app/helpers/**`, `app/assets/**`) | Implement views, helpers, frontend assets |
| `code_background_job.md` | develop step 8 / fix step 3 (when files match `lib/job_*.rb`, `lib/processor*.rb`) | Implement custom-processor jobs |
| `test.md` | develop step 9 (Test), fix step 4 (Test) | Write and run tests |
| `document_feature.md` | develop Documentation action (after Code), `/document` | Author/verify feature docs under `docs/features/` by Functional Area; log deferred work to `doc_review.md` |
| `document_yard.md` | develop Documentation action (after Code), `/document` | Apply/verify YARD on changed `.rb`; wire `@see` ↔ feature-doc `paths:` |
| `evaluate.md` | fix step 2 (Evaluate & Plan) | Triage MR feedback into fix plan |
| `spike.md` | spike pipeline | Research methodology |
| `report_issue.md` | develop pipeline error/correction paths | Log instruction gaps and AI behavior corrections to `.workspace/issue_log.md` |
| `bug_video_analysis.md` | develop pipeline Jira step (Bug tickets with video attachments) | Extract structured bug context from screen-recording videos |
| `planning_research.md` | planning step 2 | Codebase research for Features |
| `planning_external_research.md` | planning step 3 | External source research |
| `planning_breakdown.md` | planning step 5 | Story breakdown for Features |
| `planning_brief.md` | planning step 7 | Detailed story brief creation |
| `planning_attachments.md` | planning step 1 (conditional) | Download and describe Jira attachments |
| `planning_jira_create.md` | planning step 8 | Create a Jira Story from a spec file (API pattern, ADF format) |

Reference rules (read into agent context, not launched as subagents):

| File | Used by | Purpose |
|------|---------|---------|
| `./rules/integrations/github.md` | github skill, any subagent needing GitHub MCP tools | GitHub MCP tool reference |
| `./rules/integrations/jira_api.md` | develop Jira step, planning steps 1 and 6, any subagent needing Jira MCP tools | Jira MCP tool reference |
| `./rules/architecture/feature_toggle.md` | develop step 8 (Code, conditional) | `PlanSource::FeatureToggle` integration reference |
| `./rules/architecture/feature_toggle_cleanup.md` | cleanup-story development | Enabling toggles in dev/test, toggle removal procedure |
| `./rules/git/commit_trailer.md` | any agent posting Jira free-text or writing commits | AI co-author trailer convention |

---

## Ticket Types

Every workflow has a ticket key. The ticket key prefix determines `ticket_type`:

| Prefix | ticket_type | Jira | GitHub (push/MR/merge) | Auto mode |
|--------|------------|------|------------------------|-----------|
| `MDP-*` | `jira` | Yes | Yes | Yes |
| `LOCAL-*` | `local` | No | No | No (interactive only) |

### How ticket keys are resolved

The develop orchestrator resolves the ticket key during Setup:
1. If provided with no prefix (bare number) → add `MDP-` prefix
2. If not provided → ask the user. If they have no ticket → generate `LOCAL-NNNNNN`
   (sequential, based on highest existing `.workspace/LOCAL-*/` directory)
3. Set `ticket_type` in structured context — all downstream steps check this

### Which skills require Jira tickets

| Skill | Requires Jira? | Reason |
|-------|---------------|--------|
| `/develop` | No — works with both types | Core development steps are ticket-agnostic |
| `/develop fix` | Yes (structurally) | Requires an MR, which requires a pushed MDP- branch |
| `/planning` | Yes | Creates Jira Stories |
| `/jira` | Yes | Reads Jira tickets |
| `/github` | No guard needed | Naturally fails with "no MR found" for local work |
| `/code-review` | No | Reviews local changes only |
| `/setup` | No | Configures tools, not ticket-specific |

### What `ticket_type: local` means for the develop pipeline

- Jira step: skip (user provides requirements directly)
- Validate: codebase parity only (no blocker/sibling checks)
- Plan through Review: run normally
- Commit: commit locally, do not push
- Monitor/Merge: skip
- General Rules (Jira documentation): skip

---

## Local Overrides (./rules/LOCAL.md)

`.md` tells every agent to "Read `./rules/LOCAL.md`". This file contains
developer-specific preferences that override default behavior.

### Problem

Subagents might not read LOCAL.md even though .md requests it. It's a
suggestion, not a guarantee.

### Solution

**Orchestrators read LOCAL.md once** at startup and extract relevant overrides.
These overrides are passed as explicit context in each subagent's prompt:

```
Local overrides (from ./rules/LOCAL.md):
- [relevant override for this subagent's task]
```

This makes overrides part of the subagent's direct instructions, not an optional
file read.

### Override categories

When passing overrides to subagents, match by task type:

| Override topic | Pass to |
|---------------|---------|
| Commit message rules | Commit step (develop step 11, fix step 5 Review & Push) |
| Test preferences | Test agents |
| Code style preferences | Code agents, review agents |
| General preferences | All agents |

---

## Context Budget Reference

Approximate token costs for common elements:

| Element | Lines | ~Tokens |
|---------|-------|---------|
| System prompt + .md | ~200 | ~3K |
| LOCAL.md | ~100 | ~1.5K |
| Skill SKILL.md (launcher) | ~60 | ~1K |
| Agent instruction file | ~100 | ~1.5K |
| Review criteria | ~300 | ~4K |
| All guideline files | ~4,300 | ~50K |
| Relevant guidelines only | ~500-1500 | ~7-20K |

Context window: ~200K tokens. After fixed overhead, a subagent has ~150-170K tokens
for actual work (~10,000-15,000 lines of source code).

### Agent nesting depth

Some workflows create 3 levels of nesting:
- develop orchestrator → fix orchestrator → code/test subagents
- develop orchestrator → review orchestrator → review subagents

Each nesting level adds ~3-5K tokens of overhead (system prompt + instructions).
This is the trade-off for protecting orchestrator context — the alternative (running
fix/review in the develop orchestrator) risks compaction. The innermost agents do
focused work on specific files and don't need full context. If inner agents run out
of context in practice, reduce batch sizes or split the work further.

---

## Release Branch (TODO: Programmatic Lookup)

The deployment pipeline merges in this order: `develop` → release branch → `master`.

The release branch changes every Program Increment (~6 weeks). There is currently no
programmatic way to identify the current release branch name — it must be asked of the
user each time (even in auto mode).

**Future work:** A programmatic method for identifying the current release branch will
be implemented. When that's available, update:
- `skills/develop/pipelines/develop.md` (Bug cherry-pick step) — replace the
  "ask the user" instruction with the lookup method
- Any other skill/agent that needs the release branch name

Until then, every workflow that needs the release branch must prompt the user for it.

---

## Permissions (settings.local.json)

The `--- Pipeline auto-mode permissions ---` section in `settings.local.json` allows
commands to run without user confirmation. When adding new command patterns to skills:

1. Check if the command prefix is in the allowed list
2. If not, add it with the pattern `Bash(prefix *)`
3. For commands starting with variable assignments (`VAR=value && ...`), add `Bash(VAR=*)`

Known patterns that need explicit permission:
- `curl` — Jira API calls
- `source` — rvm setup
- `sleep` — pipeline polling
- `test` — environment checks
- Variable assignments: `JIRA_DOMAIN=*`, `JIRA_EMAIL=*`, `MR_IID=*`, `PIPELINE_ID=*`

---

## UX Patterns

### TodoWrite Progress Checklist

Launcher skills create a TodoWrite checklist in the **main context** before launching
the orchestrator agent. This gives users a visual progress indicator.

- Launcher creates all items as `pending`
- When the orchestrator agent returns, the launcher marks all items `completed`
- Orchestrator subagents CAN update TodoWrite (tested and confirmed). Use this for
  mid-pipeline checklist changes (e.g., replacing the develop checklist with a spike
  checklist after the Jira step reveals the ticket type).
- The agent-running UI indicator provides the "in progress" signal

### AskUserQuestion for Finite Choices

When a skill needs user input from a known set of options, use AskUserQuestion instead
of free-text prompts. This is faster for the user (one click vs typing).

Examples:
- Interactive mode step confirmation: "Proceed" / "I'll handle it" / "Skip"
- Fix pipeline wait: "Check now" / "Done for now"
- Confirmation: "Yes" / "No"

Only use free-text prompts for open-ended questions where the answer can't be predicted.

**Note:** AskUserQuestion works from subagents (orchestrators), not just main context.

---

## Compaction Handling

### Design goal: no agent should ever compact

If a workflow risks compaction, break it into smaller subagent steps. Orchestrators
must NEVER compact — they hold pipeline instructions and structured context that
cannot be recovered. If an orchestrator compacts, it may lose all coordination
state and behave unpredictably.

### Protecting orchestrator context

- Subagents do all heavy work (reading many files, writing code, running tests)
- Orchestrators only hold: pipeline instructions, structured context, and brief
  subagent result summaries
- If subagent results are large (e.g., multiple story specs), write them to files
  in the ticket workspace folder and return only file paths + brief summaries
- Operational steps (git, API calls) run in orchestrator context but produce
  limited output

### Ticket workspace folders

All pipeline artifacts for a ticket go in `.workspace/[TICKET_KEY]/`
(e.g., `.workspace/MDP-123456/`). This keeps parallel agents from
colliding and makes progress easy to check.

Orchestrators create this folder at startup and pass the path to all subagents.

| Agent type | Writes to | Filename pattern |
|-----------|-----------|-----------------|
| Plan | workspace folder | `plan.md` |
| Research | workspace folder | `research.md` |
| Planning Research | workspace folder | `codebase_research.md` |
| Planning External Research | workspace folder | `external_research.md` |
| Planning Breakdown | workspace folder | `breakdown.md` |
| Planning Brief | workspace folder | `story_N_brief.md` |
| Planning Attachments | workspace folder | `attachments.md` |
| Spike | workspace folder | `spike_report.md` |
| Code, Architecture, Design | source tree | Normal file paths |
| Test | source tree + workspace | Spec files in source tree, `test_results.md` in workspace |

Code-producing agents (Code, Architecture, Design, Test) write directly to the
source tree — their progress is tracked by the files they create/modify on disk.

### Subagent compaction recovery (progress-based retry)

"Progress" means **durable artifacts on disk** — not in-context status messages.
The Agent tool returns a single result when the subagent finishes; there is no
streaming of intermediate results. So the orchestrator detects progress by
checking what the subagent wrote before it compacted.

If a subagent compacts or returns a truncated/error response:

1. **Check for progress:** Look for artifacts the subagent should have produced:
   - Text-output agents: check the workspace folder for their output file
   - Code agents: check `git diff` or the expected file paths
   - If a partial file exists, that counts as progress
2. **If progress was made:** Launch a new subagent with the last known state. Pass
   what was completed (reference the files on disk) and what remains. The new
   subagent continues from where the previous one left off. Repeat as needed —
   as long as each attempt makes progress, keep relaunching.
3. **If NO progress was made:** The task is too large for a single subagent to make
   any headway. Stop and report to the user with:
   - What was attempted
   - Why it's too large (e.g., "too many files to read in one context")
   - Suggested manual intervention or task splitting

This prevents infinite retry loops: progress means forward movement, no progress
means the task itself needs to be broken down differently.

### Progress tracking by agent type

| Agent | How to detect progress | What to pass on relaunch |
|-------|----------------------|-------------------------|
| Plan | `plan.md` exists in workspace | "Plan partially written, continue from section N" |
| Research | `research.md` exists | "Partial findings exist, continue research" |
| Code | Files modified on disk | "Files X, Y done. Remaining: Z" |
| Test | Spec files created + `test_results.md` in workspace | "Tests for X written/passed. Still need: Y, Z. See [workspace]/test_results.md for run details" |
| Architecture | New files created | "Classes X, Y created. Still need: Z" |
| Planning Brief | `story_N_brief.md` exists | "Brief partially written, continue" |
| Planning Breakdown | `breakdown.md` exists | "Partial breakdown exists, continue from Story N" |
| Evaluate | Evaluation results returned or written to workspace | "Partial evaluation exists, continue with remaining items" |

### Rules for all orchestrator instruction files

Add to every orchestrator's critical rules:
- Create `.workspace/[TICKET_KEY]/` at startup if it doesn't exist.
- If a subagent returns an error or appears to have compacted (truncated response,
  missing expected output), apply the progress-based retry above.
- Never accumulate large results in orchestrator context. If a subagent's output
  exceeds ~50 lines, have it write to a file instead.

---

## Maintenance Checklist

When modifying skills or agents:

- [ ] Does the SKILL.md use the launcher pattern? (If >200 lines, it should)
- [ ] Do subagent prompts tell agents to read their instruction files (not duplicate them)?
- [ ] Are LOCAL.md overrides passed explicitly to relevant subagents?
- [ ] Are new command patterns covered in settings.local.json permissions?
- [ ] Does the skill work in `/develop auto` mode without user interaction?
- [ ] Is the guideline loading smart (only relevant files, not all)?
- [ ] After changes, verify total SKILL.md size (target: <100 lines for launchers;
      develop SKILL.md is ~230 due to embedded Jira step + orchestrator prompt — accepted exception)
- [ ] Co-Authored-By uses `[your model name]` — no hardcoded example to maintain
- [ ] Could any subagent accumulate enough context to compact? If so, break it down.
- [ ] Are large subagent results written to files instead of returned as text?
