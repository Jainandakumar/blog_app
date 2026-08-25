---
last_reviewed: 2026-05-21
---

# Decision log

Records non-obvious convention decisions: what we picked, what we rejected, why. Append-only — never delete an entry; if a decision is overturned, add a new entry referencing the old one.

> **Historical context.** Many entries below describe the 2026-05 migration from a `docs/` umbrella scheme (`docs/STYLE.md`, `docs/agents/`, `docs/workflows/`, `docs/local_workspace/`, etc.) into the current `./rules/`, `./agents/`, and `./tasks/` layout. Those `docs/` paths no longer exist; the only surviving `docs/` content today is `docs/features/` (the feature-doc layer). The decisions themselves remain binding — read each entry's **Decision.** line for what's still in force; the **Rejected alternatives** and historical comparisons are kept for reasoning, not for navigation.

Entry format:

```markdown
## YYYY-MM-DD — <short title>

**Decision.** <one or two sentences>

**Rejected alternatives.** <bullet list>

**Why.** <reason, including any failure mode that pushed us here>

**Revisit if.** <conditions that would make us reconsider>
```

---

## 2026-05-19 — ~200-line soft cap on instruction files

**Decision.** Skills, agents, and rule files target ≤200 lines. Split when over.

**Rejected alternatives.**
- 300-line cap (proposed in earlier `documentation_structure_plan.md`).
- Per-layer caps (150 agents / 200 rules / 300 skills, also proposed earlier).

**Why.** Anthropic publishes <200 lines as guidance for .md; adopting it portably across all instruction files keeps the rule simple. Above ~200 lines, model adherence drops in long files, and the bigger the file the more its content competes for attention.

**Revisit if.** A category of content emerges where 200 lines genuinely fragments meaning. Override per-file and log the reason here.

---

## 2026-05-19 — Subagents always live in `./agents/`

**Decision.** Every subagent instruction file goes in `./agents/<name>.md`. Even single-use ones. No subagent prompts inline in skill pipeline files.

**Rejected alternatives.**
- Bundle single-use subagents inside the skill's own folder.
- Inline subagent prompts in pipeline files (status quo).

**Why.** Inventory found 9 inline subagent prompts inside skill pipelines (most notably in `develop/pipelines/develop.md`, 738 lines). Centralizing makes subagents discoverable, swappable across skills, and uniformly governed.

**Revisit if.** A subagent grows so tightly coupled to a single skill's internal state that referencing-by-path becomes awkward. Currently no candidate.

---

## 2026-05-19 — Three loading modes (explicit default; universal allowed; path-scoped rare)

**Decision.** Rule files use Mode A (explicit read, default), Mode B (universal, every session), or Mode C (path-scoped auto-attach). Mode A is the default; Modes B and C are exceptions justified case by case.

**Rejected alternatives.**
- Explicit-read only (no universal, no path-scoped). Rejected because some rules (communication patterns, code-placement) genuinely apply to every session and forcing every agent to remember them creates a maintenance burden.
- Universal-heavy (default many rules to Mode B). Rejected because every byte costs context every session.

**Why.** Three modes give us a tiered approach: most rules are explicit (caller-driven, predictable context), a small foundational set is universal (always-loaded, can't be forgotten), and a rare few are path-scoped (auto-attach when matching code is read).

**Revisit if.** The universal set grows beyond 3–5 files or 300 lines total — audit for content that should be moved to Mode A.

---

## 2026-05-19 — Separate-but-synchronized .md and AGENTS.md (not `@import`)

**Decision.** .md and AGENTS.md are two distinct files with overlapping content. We do NOT use Anthropic's `@AGENTS.md` import syntax.

**Rejected alternatives.**
- `@import` pattern (.md does `@AGENTS.md` plus -specific extras).
- .md as source of truth, AGENTS.md as a minimal pointer.

**Why.** AGENTS.md serves a real audience (non- tools like AiDE) that may not honor 's `@import` syntax. Keeping the files separate preserves AGENTS.md's standalone readability.

**Revisit if.** AiDE is retired or all non- tooling reliably honors `@import`. At that point .md `@AGENTS.md` becomes attractive.

**Mitigation.** `/author audit` will include a sync-check that compares universal-rule sections between the two files.

---

## 2026-05-19 — Hybrid fold for `docs/agents/` (not duplicate-into-agents)

**Decision.** Move `docs/agents/<ROLE>.md` content as follows: extract universal content (e.g. `orchestrator/communication.md`) to `./rules/`, then fold role-specific content into the matching `./agents/<name>.md`. Delete `docs/agents/`.

**Rejected alternatives.**
- Fold each role file into the matching agent file (duplicates universal content across agents).
- Keep `docs/agents/` as separate role rule books (adds an indirection layer).

**Why.** Hybrid honors the no-duplication rule (universal content in one place) and the explicit-reads rule (agent files name what they read). The earlier plan assumed `docs/agents/` was a duplicate of `./agents/`; inventory found it is NOT — ~959 lines of unique content.

---

## 2026-05-19 — `agent-testing` skill retired

**Decision.** Delete `docs/workflows/agent_testing.md` (890 lines) outright. Do not promote to a skill.

**Rejected alternatives.**
- Promote to `./skills/agent-testing/` as its own skill.
- Split into multiple rule files in `./rules/testing/agent_testing/`.

**Why.** The file was built when we authored AI instructions for multiple LLM tools (, AiDE, others) and needed cross-tool testing. We are now -only — instructions are designed for  conventions. The cross-tool test harness no longer matches our actual usage. The file is recoverable from version control if ever needed again.

**Revisit if.** We adopt a second AI tool with different conventions and need to validate cross-tool instruction adherence.

---

## 2026-05-19 — AiDE integration docs live in `.aide/`, not `./` (revised during Phase 7)

**Decision.** AiDE-specific content lives at `.aide/README.md` (repo root). Referenced from `AGENTS.md` as a one-line "Integrations" entry.  never reads it; nothing AiDE-specific appears in `./`.

**Rejected alternatives.**
- Fold into `./README.md`. Rejected —  doesn't need to know AiDE exists.
- Move to `docs/integrations/aide.md`. This was the initial plan but rejected during Phase 7 review: the file is for AiDE users only, not part of the application's documentation, so the dedicated `.aide/` folder (which already houses `.aide/mcp.json`) is the more natural home.
- Migrate the doc as-is. Rejected because the source file mixed three audiences (AiDE-specific, general dev onboarding already covered by `/setup`, stale MCP version pins) — only the AiDE-specific bits warranted preserving.

**Why.** AiDE is a third-party agentic tool used by an external development team as a  alternative. It consumes `AGENTS.md` plus the `.aidemodes` definitions at the repo root. Putting AiDE content in `./` pollutes 's context with information about a sibling tool. Putting it in `docs/integrations/` mixes it with application documentation. `.aide/` co-locates AiDE config (`mcp.json`, `.aidemodes`) with AiDE docs (`README.md`). If AiDE is retired, the folder deletes cleanly with no -side references to repair.

**What was dropped from the source file.** General dev onboarding (SSH access, env vars, credential files, MCP pre-cache, git hooks, `/setup verify`) — all covered by `/setup`. Stale MCP version pins (v1.2.0/v1.1.0 vs the canonical v1.6.0/v1.3.2 in `./skills/setup/components/`). The confluence MCP reference (not in current `/setup`). The redundant slash-command reference table.

---

## 2026-05-19 — Universal rule set seed

**Decision.** Three rules launch into Mode B (universal) at the start of the refactor:

- `./rules/communication.md` (folded from `docs/agents/orchestrator/communication.md`, ~199 lines but reduce to ≤80 during fold).
- `./rules/architecture/code_placement.md` (~62 lines per inventory).
- `./rules/meta/cross_references.md` (~60 lines, newly authored).

**Rejected alternatives.**
- Only `cross_references.md` (the new file) starts as universal; everything else stays explicit-read until proven needed.
- Multiple additional candidates (workspace_output, ai_coauthor_trailer, etc.) — kept as explicit-read because they don't apply to every session.

**Why.** These three apply to every session (communication is how agents talk back; code placement applies whenever code is added; cross-references explain a foundational system convention). Each is small enough that the universal cost is acceptable.

**Revisit if.** Combined universal set exceeds 300 lines or the universal rule count exceeds 5.

---

## 2026-05-19 — `communication.md` qualifies for Mode B (universal)

**Decision.** `./rules/communication.md` carries `universal: true` and loads in every session. Folded from `docs/agents/orchestrator/communication.md` (199 lines) and trimmed to 71 lines for the universal cap.

**Rejected alternatives.**
- Mode A explicit-read by every agent file. Rejected because forgetting the read causes communication drift (over-excitement, weak pushback, missed "user repeatedly unhappy" signal) — exactly the failure mode this rule prevents.
- Keep in `docs/agents/orchestrator/` as an orchestrator-only rule. Rejected because inventory established the content applies to every agent (tone, pushback, subagent reporting back), not just the main session.

**Why.** Communication style is the lever the user perceives most directly. The rule applies to every interaction the user observes — main session and subagent summaries alike. Universal loading is appropriate because every byte spent on this rule pays back in every session.

**Trimming approach.** Removed the worked examples that occupy ~80% of the original 199 lines. The instruction_authoring.md convention is that universal-mode rules carry rules, not long expositions — examples can live in `./skills/author/` if they're needed for authoring guidance later. The rule cap is 80 lines (per §5 of instruction_authoring.md); 71 leaves headroom for the inevitable small additions.

**Revisit if.** The universal-rule total exceeds 300 lines (currently three rules totalling well under that) or the universal-rule count exceeds 5.

---

## 2026-05-19 — External tool dependencies live in `/setup`

**Decision.** Every skill ensures `/setup verify` has succeeded for the current session before doing real work. Skills and agents that use external CLI tools (ffmpeg, ImageMagick, jq, etc.) assume the tool is installed and just use it — no presence checks, no install instructions, no per-platform branching. Captured as a new rule in `./rules/agent_authoring/external_dependencies.md`.

**Rejected alternatives.**
- Status quo: each skill/agent includes its own `which <tool>` check and `brew install` fallback. Rejected because it creates inconsistency across files, bloats skill/agent prose, and obscures the project's true dependency surface.
- Have skills emit `NEEDS_DECISION: tool not available` when a tool fails. Rejected because the user clarified the cleaner pattern: `/setup` runs first, tools are guaranteed available, so this branch shouldn't exist.

**Why.** Found during Phase 5 of the cleanup: the freshly-wired `bug_video_analysis` agent included ffmpeg install instructions, AND `develop/SKILL.md` had ~25 lines of orchestrator-level branching for ffmpeg presence/absence. Same tool, two places, both restating install paths. The convention concentrates dependency management in `/setup` so every skill/agent can focus on its real work.

**Cross-platform implication.** When new OS support is needed (Linux, WSL), only `/setup` changes — the rest of the instruction layer stays portable. Future setup files (`setup-mac.md`, `setup-linux.md`) live under `/setup` and the skill picks based on host OS.

**Revisit if.** A future skill genuinely needs to degrade gracefully on a missing tool (e.g. "produce a reduced-feature output if X isn't available"). Currently no candidates — the contract is "tools are present because `/setup` ensured them; if not, the user runs `/setup`."

---

## 2026-05-19 — Runtime skill/agent instructions give directives, not authoring-rule citations

**Decision.** When a skill or agent instruction directs an action that comes from a convention (e.g. "ensure `/setup verify` has succeeded"), write a plain directive. Do NOT cite the convention rule (e.g. NOT "Per `./rules/meta/instruction_authoring.md` §10, every skill ensures..."). The citation belongs in `/author`-managed authoring contexts only.

**Rejected alternatives.**
- Always cite the authoring rule that motivated a directive. Rejected because runtime agents don't benefit from the citation — they need to *do*, not *learn why*. The citation also risks inviting the agent to fetch the cited file, polluting context with content irrelevant to its task.
- Drop the directive entirely and rely on the agent having read the meta rule. Rejected because runtime skills/agents do NOT read the meta authoring rules — those are for `/author`.

**Why.** Found during Phase 6b when the user inspected freshly-edited `jira/SKILL.md` and asked: "do we really want to reference `./rules/meta/instruction_authoring.md` at all in these instructions? Does that make it more likely that it might read that file?" Both concerns are real: (a) the directive is self-contained without the citation, (b) citations leak authoring concerns into runtime files. Skills carry directives; they don't carry rule attribution.

**Revisit if.** A directive becomes complex enough that knowing the rule it implements adds real value (e.g. multi-step procedure tied to a specific convention edge case). At that point the directive should probably be its own rule file, with the skill referencing the rule file — same as any other explicit-read.

---

## 2026-05-20 — Content discipline (what NOT to include in instruction files)

**Decision.** Captured in `./rules/meta/content_discipline.md` and referenced from instruction_authoring.md §10. Every sentence in a skill/agent/rule file should help the reader do its job. Specifically, do NOT include "don't do X" or "we do Y because Z" lines for things the agent wasn't already working with — they introduce out-of-scope concepts that compete for attention and expand the agent's decision space.

**Rejected alternatives.**
- Add the discipline as a single short rule inside instruction_authoring.md. Rejected because the discipline needs concrete worked examples (good/maybe/bad patterns) and would either bloat instruction_authoring.md past the line cap or be too compressed to be actionable.
- Treat it as implicit best practice. Rejected because we're already finding cases mid-cleanup where authors (subagents and humans) reach for "don't" lines that introduce out-of-scope concepts.

**Why.** User flagged during Phase 6c that several instruction files we authored may contain "don't do X" lines for out-of-scope behavior. Mid-cleanup is the right time to capture the discipline AND audit what we've already written.

**Implementation.** `/author` skill's Universal Expectations now includes `content_discipline.md` as a reference read. A follow-up review pass will scan existing skills/agents/rules for content-discipline violations and propose fixes.

**Revisit if.** We find this discipline is too restrictive (e.g. some clarifying "don't" lines genuinely help) — relax with new examples in content_discipline.md.

---

## 2026-05-20 — `last_reviewed:` frontmatter is intentional custom metadata

**Decision.** Keep the `last_reviewed: YYYY-MM-DD` field on rule files (and feature docs) even though VS Code's instruction-file linter doesn't recognize it ("Hint" severity diagnostic on every rule file).

**Rejected alternatives.**
- Rename to use a field VS Code knows. Rejected — none of VS Code's known fields (`description`, `paths`) carry the same semantic.
- Move the timestamp into a comment or a separate sidecar file. Rejected — frontmatter is the cleanest, most discoverable location, and the convention is already used across all rule files.

**Why.** `last_reviewed` is project metadata for human/audit use (and future drift-detection tooling per instruction_authoring.md §11 — `last_reviewed` field). It is not consumed by VS Code or by any current Anthropic spec. The hint is informational.

**Revisit if.** Anthropic adds an official field that covers the same semantic; or VS Code's hint becomes a warning/error.

---

## 2026-05-20 — `/setup` defers to upstream MCP setup via a Tool (goal)

**Decision.** Long-term direction: each MCP server exposes a `mcp__<server>__setup` Tool that returns setup instructions (and/or performs setup actions) for that server. Consumer `/setup` skills become thin wrappers that pre-cache the MCP package declared in `.mcp.json` and then call the Tool. The Tool encapsulates env var names, config file shapes, version-check logic, and verification — single source of truth at the MCP. Today (post-Phase 6d), `./skills/setup/components/mcp_atlassian.md` and `mcp_github.md` carry the install logic inline; this stays until the MCPs add the Tool.

**Why a Tool, not a Resource or a Prompt.**
- **Tools work without auth.** MCP tools are visible/callable as soon as the MCP connects — auth only gates the *actions* a tool performs against external systems. Setup tools don't call external systems; they return local state and instructions, so no auth gate.
- **Tools are universally discoverable.** Listed by default on connection in every client. Resources require explicit `list_resources` discovery and are surfaced inconsistently across clients.
- **Tools can be stateful.** `mcp__<server>__setup()` can introspect current state (token present? config file present? version matches?) and return only the next-needed step. Resources are best for static content.
- **Tools collapse skill machinery.** Anyone connecting to the MCP from any client can call the Tool — no consumer-side skill required. Drops the need for `components/<server>.md` files entirely if a client wants to skip the wrapper.
- **Prompts are wrong layer.** They put the MCP in the user-interaction driver seat; consumer `/setup` should remain the single UX flow, just calling the Tool for its instructions.

**Chicken-and-egg solution.** The pre-install step (`npx --yes --package "<URL>#<vX>" ...`) stays consumer-side, but only because the MCP isn't running yet. The package URL + version are declared in `.mcp.json` (already in the consumer repo) — so the consumer's pre-install step is "pre-cache whatever `.mcp.json` declares" without restating the URL. After pre-cache +  Code restart, the Tool is available and drives everything else.

**Target consumer-side shape (post-Tool):** ~5 lines per MCP server.
1. Pre-cache the MCP package declared in `.mcp.json`.
2. Call `mcp__<server>__setup()` and follow the returned instructions until it reports "all set."

**Rejected alternatives.**
- A generic skill-composition / skill-injection mechanism. Rejected as out of scope and premature.
- An MCP Resource (`mcp://<server>/setup-skill`). Rejected because Tools are more discoverable, work in more clients, and can be stateful without needing query args.
- An MCP Prompt that drives the setup UX. Rejected because it fragments user experience across MCPs and competes with the consumer's `/setup` as the UX driver.
- Slim the per-component MCP files immediately to point at a checked-out MCP `SETUP.md`. Rejected because consumers install via `npx` and don't have the MCP source.

**Why.** Surfaced during Phase 6d when the user asked: "Each of the MCPs has its own 'example setup skill' — wouldn't it be easier to just call into that?" The duplication is real (every consuming repo restates the install commands and the version pin). The MCP repos (`git@git.plansource.com:mcp/atlassian`, `mcp/github`) currently ship `examples/setup-skill.md` as copy-templates with a deliberate three-section structure (Environment Check / MCP Configuration / Verify) and a security note about not naming env vars in skill control flow. The Tool design subsumes both files into runtime-served content with the same security boundaries.

**Revisit if (action triggers).** (1) An MCP adds `mcp__<server>__setup` — slim the consuming component to the ~5-line wrapper. (2) A second consuming repo is asked to update MCP version pins manually — pain threshold reached, prioritize adding the Tool. (3) The cross-MCP setup procedure diverges enough that the consumer-side composite breaks.

**MCP-side work (separate tickets, not this branch).**
- Implement `mcp__<server>__setup` Tool on both `atlassian` and `github` MCP repos.
- Update `examples/setup-skill.md` to describe the Tool's contract or replace it with a Tool reference.
- Fix the slight tension in the current example preamble (says "skill doesn't name env vars" but the user-facing instructions block does).

---

## 2026-05-20 — Append-only log files exempt from the line cap

**Decision.** Append-only log files (currently `decision_log.md`) are exempt from the ~200-line cap in `instruction_authoring.md` §4. Captured as a new clause in §4. The `/author audit` line-count check should skip files identified as logs.

**Rejected alternatives.**
- Periodically split the log into yearly archives (`decision_log_2026.md`, etc.). Rejected because cross-referencing decisions across archives is painful and the log is the canonical authority for "why a convention exists" — fragmenting it weakens that authority.
- Trim older entries when the log grows large. Rejected because the value of the log is its completeness; pruning historical entries defeats the purpose.
- Move older entries into individual per-decision files. Rejected because the log's chronological narrative is part of its value — readers scan top-to-bottom to understand the evolution of conventions.

**Why.** Surfaced during the Phase 12 audit: `decision_log.md` was 253 lines (over the cap). The cap exists to protect model attention on instruction files that the model reads as guidance. The decision log is reference material consulted for specific entries; reading it top-to-bottom is rare and only done by the `/author` skill itself. The growth pattern (append-only, ~10 entries per major refactor) means a fixed cap creates ongoing pressure to delete history.

**Revisit if.** Another file type emerges that is genuinely append-only and reference-style (not directive). The exemption should be granted explicitly per file type, not as a blanket "logs are exempt."

---

## 2026-05-20 — `instruction_authoring.md` slight overage acceptable

**Decision.** `instruction_authoring.md` is currently 211 lines (over the 200-line cap by ~5%) due to the §10 (content discipline) and §4 (log exemption) additions during this refactor. Keep as-is rather than artificially compressing.

**Rejected alternatives.**
- Trim §10 to 3-4 lines and rely entirely on `content_discipline.md`. Rejected because §10 needs to communicate the self-check (steps 1-3) inline; without it, agents reading §10 wouldn't know what to apply when authoring.
- Move the 12 numbered rules into separate files. Rejected because the numbered list is the canonical contract; fragmenting it weakens the "these are the conventions" framing.

**Why.** The cap is a soft target. The file is the canonical conventions index — every numbered rule earns its line count. Forcing a split would harm comprehension of "what conventions apply when authoring."

**Revisit if.** The file grows past ~230 lines. At that point split out individual rules (e.g., move §11 §12 into a separate file).

---

## 2026-05-21 — `issue_log.md` is local-only pending GitHub Issues integration

**Decision.** `./tasks/issue_log.md` (written by the `report_issue` agent) stays gitignored. The previously-added `.gitignore` exception (`!/./tasks/issue_log.md`) is removed. Each developer's log is local to their machine; there is currently no cross-developer visibility.

**Rejected alternatives.**
- Keep the file committed (status quo). Rejected: append-only file across parallel work guarantees merge conflicts, and devs would have to remember to commit it after each pipeline run.
- Delete the file and the `report_issue` agent entirely. Rejected: the agent's plumbing in `/develop` is useful; we just need a better backing store than git.
- Push to Jira (`mcp__jira__create_issue` already exists). Rejected for now: Jira is for product work; mixing AI-instruction-maintenance feedback into the product backlog adds triage noise for the product team.

**Why.** User-flagged during MDP-235157 MR review: committing this file would create merge conflicts on every parallel session that logs an entry. GitHub Issues are the natural fit — queryable, labelable, assignable, zero git conflicts — but the github MCP doesn't yet expose `create_issue` or `add_issue_comment` tools. The local-only file is the bridge until that integration ships.

**Follow-up work (separate ticket).** Add `mcp__github__create_issue(title, description, labels?)` and `mcp__github__add_issue_comment(issue_iid, body)` to the github MCP (mcp/github repo). Then update the `report_issue` agent to call the new tool. Then delete `./tasks/issue_log.md` from instructions entirely (any per-dev local copies become inert). The maintainer can pick between a dedicated project, a label on ' tracker, or a single threaded issue — recommend dedicated project for cleanest triage.

**Revisit if.** (1) Cross-dev visibility becomes painful before the github MCP integration ships — could route to Jira as an interim. (2) The follow-up ticket lands; this entry gets superseded by an entry documenting the GitHub Issues design.

---

## 2026-05-27 — Workspace path stays `./tasks/{ticket}/` (not `./workspace/`)

**Decision.** During headless-readiness adoption (`./headless/headless-readiness.md`), the checklist proposes `./workspace/{workspace_id}/` as a unified workspace path. We keep our existing `./tasks/{ticket}/` instead.

**Rejected alternatives.**
- Rename `./tasks/` → `./workspace/`. Rejected: would require updating 30+ skill, agent, and rule files plus their cross-references — high churn, low value. Our existing path semantics already match the checklist's intent (per-ticket workspace folder, gitignored content, README.md exempt).
- Maintain both paths in parallel. Rejected: doubles maintenance burden; agents would have to guess which path applies.

**Why.** Naming is cosmetic; semantics matter. `./tasks/{ticket}/` already implements the unified workspace pattern: flat path per ticket, gitignored, README.md exempted to keep the directory tracked. The headless checklist's intent (single workspace location settled before subagent launch, passed by ID, never auto-deleted on success) is fully covered by our existing convention.

**Revisit if.** A future  Code feature reads `./workspace/` specifically (none today), or the wider ecosystem standardizes on that name.

---

## 2026-05-27 — Snake_case naming preserved for agents/rules (not kebab-case)

**Decision.** During headless-readiness adoption, the checklist proposes kebab-case for all filenames (agents, skills, rules). We keep our existing snake_case for agent files and rule files; skill folders remain lowercase-hyphen as defined in `instruction_authoring.md` §6.

**Rejected alternatives.**
- Rename 28 agents + ~100 rules + every cross-reference. Rejected: days of mechanical work + breakage risk for negligible gain.
- Adopt kebab-case for new files, leave existing files as snake_case. Rejected: produces a mixed convention worse than either pure choice.

**Why.** The checklist's stated rationale for kebab-case is "no underscores, no spaces" — snake_case satisfies "no spaces" and is widely used by Anthropic's own examples. Our current convention in `instruction_authoring.md` §6 (skill folder = lowercase-hyphen; everything else = snake_case) is internally consistent and provides clear visual distinction between folder names and content files.

**Revisit if.** Anthropic's official tooling becomes strict about kebab-case across `./`, or the wider ecosystem standardizes.

---

## 2026-05-27 — MR creation/merge uses git push options + MCP (no forge scripts)

**Decision.** During headless-readiness adoption, the checklist proposes `./scripts/{forge}-pr.sh` wrapping `gh pr create` / `glab mr create`. We do not adopt this pattern. MR creation uses `git push -o merge_request.create=true` (git push options); MR merge uses `mcp__github__merge_mr` (existing MCP tool). The `./scripts/` folder is not created.

**Rejected alternatives.**
- Create `./scripts/glab-mr.sh` wrapping `glab mr create`. Rejected: GitHub's push options already create the MR atomically with the push — wrapping a CLI adds latency and dependency without value.
- Use raw `curl` against the GitHub API. Rejected: requires on-disk tokens; the MCP server already encapsulates auth correctly.

**Why.** The checklist assumes the forge CLI is the canonical creation path. For GitHub, push options provide the same outcome with one fewer process boundary and no extra credential handling. The PreToolUse observability hook called for in §4 of the checklist can live inline in `settings.json` (consistent with the existing inline PostToolUse touched-files hook).

**Revisit if.** (1) A skill genuinely needs multi-line forge logic that's awkward inline (e.g., Teams notification with retries — see next entry). (2) GitHub deprecates push-option MR creation.

---

## 2026-05-27 — Teams (not Slack) for human-in-the-loop escalation; instruction layer stays platform-agnostic

**Decision.** Where the headless-readiness checklist references Slack for escalation, we will use Microsoft Teams. The source `headless-readiness.md` checklist is updated accordingly. However, the instruction layer (skills, agents, rules) stays platform-agnostic: skills write `state/escalation.json` and an external watcher (built later) is responsible for posting to Teams. No Teams-specific code lives in `./`.

**Rejected alternatives.**
- Write Teams webhook calls directly into skill instructions. Rejected: couples skills to a specific platform; hard to swap or test; mixes orchestration with notification plumbing.
- Build a `./scripts/teams-notify.sh` now. Rejected: no concrete Teams contract yet (webhook URL? Bot framework? Power Automate?); premature.

**Why.** The escalation contract is "write a structured JSON file and stop"; the watcher reads it and notifies. This keeps the instruction layer reusable across notification platforms and lets the watcher evolve independently.

**Revisit if.** A Teams MCP becomes available (preferred path) or the watcher contract crystallizes enough to warrant a dedicated script.

---

## 2026-05-27 — Four-mode pipeline taxonomy + three-tier headless escalation

**Decision.** The pipeline-mode set expands from three to four:

- **interactive** (default) — pauses for user input; existing behavior.
- **guided** — runs silently with a single confirmation before commit; existing behavior.
- **auto** — no `AskUserQuestion`; stops on `NEEDS_DECISION` (user is watching locally); existing behavior, semantics clarified.
- **headless** (NEW) — no `AskUserQuestion`; on `NEEDS_DECISION` triggers a three-tier escalation: (1) orchestrator attempts to resolve from context, (2) writes `state/escalation.json` and stops with a wait timer (default 30 min, configurable), (3) on resume-after-timeout, force-commits workspace + pushes + updates ticket + writes blocker.md + exits.

Detection: keyword (`headless`, `unattended`, `non-interactive`) in `$ARGUMENTS`, OR `_CODE_ENTRYPOINT=sdk-cli` env var (the signal  Code sets in ` -p` mode). Persisted to a shared `./tasks/{ticket}/STATE.md` with a `skill:` field so the develop skill can pick up planning context (and vice versa).

Workspace lifecycle (headless mode, develop skill only):
- Before any push on a blocker: `git add -f ./tasks/{ticket}/` + commit (workspace preserved on branch).
- Before the final push that creates the MR: force-commit workspace, then `git rm -rf ./tasks/{ticket}/` + commit (workspace in branch history but not in final state — never enters main).
- On `--resume` after the removal commit: `git checkout HEAD~1 -- ./tasks/{ticket}/` to recover.
- After MR merged: workspace cleanup (`rm -rf ./tasks/{ticket}/`).

`/planning` does not force-commit on blocker (no branch context). Workspace stays local; limitation accepted for now.

**Rejected alternatives.**
- Conflate `auto` and `headless`. Rejected: they differ in `NEEDS_DECISION` behavior; "user is watching" vs "no user" needs distinct semantics.
- Use only the keyword for detection. Rejected: misses the case where a developer invokes ` -p` without thinking to add the keyword; env-var detection is fail-safe.
- Make headless behavior orthogonal to mode (flag rather than mode). Rejected: introduces a 4-state matrix when 4 modes suffice.

**Why.** The current three-mode model assumes a user is always reachable. Headless adds the case where no user is reachable for an indeterminate window; the three-tier escalation lets the pipeline make forward progress (or fail safely with full state preservation) without a watcher in the loop. The workspace lifecycle ensures resumability survives session boundaries while keeping the main branch clean.

**Stub-only implementation in this branch.** Tier 2 (Teams notification, wait-timer enforcement) and Tier 3 (background-watcher-driven resume) are documented contracts only. Skills emit `state/escalation.json` and stop; the external watcher and Teams plumbing are future infrastructure.

**Revisit if.** (1) The watcher infrastructure lands and the JSON contract needs to evolve. (2) Wait-timer defaults need per-skill customization. (3) A pattern emerges where `auto` and `headless` semantics should re-converge.

---

## 2026-05-28 — Workspace path moves from `./tasks/` to `.workspace/` (SUPERSEDES 2026-05-27 entry)

**Decision.** Move the per-ticket workspace from `./tasks/{ticket}/` to `.workspace/{ticket}/`. The runtime log location moves from `./tasks/_runtime/tool-calls.log` to `.workspace/_runtime/tool-calls.log`. This **supersedes** the 2026-05-27 entry "Workspace path stays `./tasks/{ticket}/` (not `./workspace/`)" — that decision was based on the wrong assumption that the path choice was cosmetic.

**Rejected alternatives.**
- Keep `./tasks/` and fight the permission gate. Rejected: empirically verified that  Code's permission gate has hardcoded sensitivity for any path under `./`. Explicit `Write(./tasks/**)` and `Bash(mkdir -p ./tasks/**)` allow rules in `settings.json` are **not honored** — both interactive and headless modes prompt or deny on every `./tasks/` write. Interactive mode papers over this with a user prompt (which a developer can click through); headless ` -p` has no user to click, so the entire pipeline halts at workspace creation in Step 1 / Phase 0.
- Use `--dangerously-skip-permissions`. Rejected: defeats the security model and was explicitly declined by the project owner.
- Patch the permission system. Rejected: not under our control.  Code's sensitivity heuristic is hardcoded and undocumented.
- Move workspace to `.tasks/` or `.ai-workspace/`. Rejected in favor of `.workspace/` for being short, generic, and verified-clean via direct write tests.

**Why.** Reproduced on 2026-05-28 with a clean settings reload: writes to `.workspace/test-probe/` proceeded without a prompt; writes to `./tasks/test-permission-probe/` triggered a permission prompt despite explicit `Write(./tasks/**)` allow rule. Same session, same settings, only the path differed. This is the empirical evidence that `./` is hardcoded-sensitive in  Code's permission gate, and allow rules are not the lever.

**Implementation.**
- `.gitignore`: add `/.workspace/*` with `!/.workspace/README.md` exception (mirror existing `./tasks/*` pattern).
- `./settings.json`: update PreToolUse hook `LOG_DIR` to `.workspace/_runtime`.
- All instruction files (skills/agents/rules/headless/usage/entry files) that reference `./tasks/{ticket}/` updated to `.workspace/{ticket}/`.
- Existing `./tasks/*` content (past planning artifacts, the headless-readiness/plan.md, current `_runtime/` logs) **stays where it is** as a historical archive. Not moved. Will be cleaned up later.
- The 2026-05-27 entry stays in this log as the prior decision; this entry is the active one.

**Revisit if.**  Code adds a documented mechanism to override `./` sensitivity (e.g., a new setting or an explicit "trust this subpath" rule), at which point we could move workspaces back inside `./` if there's reason to.

---

## 2026-08-03 — Feature-level review is a new pipeline under `/code-review`, not a new skill

**Decision.** Add a Feature-level review capability (review a whole Feature's child tickets together, once the Feature is complete, and post a findings report to the Jira Feature ticket) as a new pipeline dispatched from the existing `code-review` skill (`feature_review_instructions.md`, plus three new agents: `feature_review_fetch`, `feature_review_coverage`, `feature_review_synthesis`). Dispatch is by argument shape in `SKILL.md` Step 0: a ticket-key-shaped argument routes here; otherwise the existing branch-review pipeline runs.

Two further decisions bundled into this one:

1. **Current `develop` state is the source of truth for requirement coverage, not commit-message tracing.** Commit search by ticket key (no date bound needed — every commit carries its exact ticket number by convention, enforced by a GitHub pre-receive hook) still runs, but only to seed a candidate file list and a Pronto base ref — explicitly documented as "a floor, not a ceiling" in `feature_changes.md`. The hook guarantees a ticket number is *present*, not that it's *correct*, and a requirement can be satisfied by code that predates the Feature entirely (no commit will ever point at it). `feature_review_coverage` is required to widen its search past the candidate list before concluding a requirement is missing.
2. **Advisory Findings are a new, separate output category**, governed by a new rule file (`./rules/code_review/advisory_findings.md`), scoped to this pipeline only. Judgment calls (intent-vs-documentation gaps, usability, inconsistency with similar code, spec/requirement critique, ambiguous dead code) are surfaced but never mixed with concrete Known Issues, and never get the "prompt to fix" treatment `review_criteria.md`'s issues get.

**Rejected alternatives.**
- A wholly new standalone skill (`/feature-review`). Rejected: `/code-review` had no ticket-key argument handling at all before this, so new dispatch logic was needed either way; a new pipeline reuses `review_criteria.md` and the existing Pronto-handling in `review_instructions.md` (now parameterized with an optional base-ref override) without duplicating either, and mirrors the `/develop` skill's own develop/fix/spike pipeline-dispatch precedent.
- Gating completion on every child ticket reaching `Done`. Rejected in favor of `Testing (QA)` or `Done` — waiting for full QA sign-off would mean the integration review runs *after* QA instead of before/during it, which is backwards for a review whose point is catching integration gaps early.
- Requiring commits for every child issue type. Rejected — Spikes are research-only (no MR by convention) and DevOps Requests are often infra work outside this repo; only Story/Bug children are gated and required to show coverage. Other types are recorded for context only.
- Folding the advisory-findings exception into `review_criteria.md` directly. Rejected: that file's entire "What NOT to Comment On" section exists to suppress speculation for the per-ticket review; mixing an opt-in exception into the same file risked confusing that contract. A separate file, referenced only by the Feature pipeline, keeps both rules legible on their own.
- Having subagents read `develop`'s current file content via `git show <ref>:<path>` (no checkout). Rejected: it would work, but every other review agent in this codebase already just reads local files directly. Instead, the orchestrator (top-level session, which owns state-changing git per `AGENTS.md`) safely checks out `develop` for the duration of the review (stashing uncommitted work first if needed) and restores the original branch afterward — subagents keep using plain `Read`/`Grep`/`Glob` like everywhere else.

**Why.** Surfaced while designing the review: individual per-ticket reviews already verify a diff against stated requirements, but nothing previously checked whether the *sum* of several tickets' diffs actually satisfied the Feature they were split from — exactly the gap where scope silently drops between tickets during breakdown, or two tickets' independent work never gets wired together.

**Revisit if.** (1) A second consumer wants the advisory-findings category (e.g. an opt-in mode for the per-ticket review) — revisit whether it should move to a shared location. (2) The commit-tagging hook is ever made to validate the ticket number itself (not just the pattern), which would let coverage lean more on commit attribution and less on full current-state re-verification.

---

## 2026-08-03 — Feature review: no completion gate, real Jira checklists, and a ticket-action step (supersedes part of the entry above)

**Decision.** Four changes to the Feature-review pipeline designed above, made together during a second design pass before any of it shipped:

1. **The completion gate is removed entirely** — this **supersedes** the "Gating completion... Testing (QA) or Done" line in the 2026-08-03 entry above. A Feature can be reviewed in any state; some child tickets are *expected* to stay open past the review (e.g. a toggle-cleanup ticket deferred to next release). Ticket status becomes a framing signal on each finding (`Tracked by: [ticket] ([status])`), never a precondition for running the review at all. `feature_review_fetch` fetches and searches commits for **every** child ticket regardless of type or status (not just Story/Bug) — this also means a commit landing under a Spike or DevOps Request (which shouldn't have code) is now itself a reportable observation, and so is a Story/Bug with zero matching commits. Neither fits the Known Issue / Advisory Finding split (they're not code defects and not judgment calls), so they get a third, lightweight, non-checklist "Ticket Tracking Notes" section in the report.
2. **A real, checkable Jira checklist**, not a workaround. `add_comment`'s markdown-to-ADF conversion doesn't turn `- [ ]` into an actual checkbox — it was going to render as literal bracket text. Rather than accept that and re-post a fresh disconnected comment on every review, we extended the Atlassian MCP server (`git@git.plansource.com:mcp/atlassian`, `.mcp.json` pin bumped `v1.8.0` → `v1.9.0`) with `post_feature_review_checklist`, modeled directly on the existing `update_acceptance_criteria` tool's read-modify-write-by-`localId` pattern. `feature_review_synthesis` now diffs each run's findings against the previous run's checklist (matched by ticket key + normalized title) and updates the *same* comment — resolved items get checked off, still-open items are left alone, new items are appended.
3. **Optional ticket actions for Known Issues, offered after posting, never automatic.** The pipeline always documents every finding in the Feature comment first; only then, and only in interactive/guided mode, does it offer to create a new ticket (reusing `planning_jira_create` as-is) or add a comment to an existing open ticket (`feature_review_ticket_update`, new) for a *user-selected* subset of Known Issues. Advisory Findings never get this offer — they're judgment calls meant to start a conversation, not spawn tracked work.
4. **A new interactive gate before anything posts**, governed by `feature_review_interactive_ux.md`. The user can question, correct, or add context to any finding, which can *reclassify* an item between Known Issues and Advisory Findings — but reclassification changes framing, never removes documentation. "We already knew about this" is grounds for moving something to Advisory with that context attached; it is never grounds for deleting it from the report.

**Rejected alternatives.**
- Keep the `Testing (QA)` / `Done` gate and let the user override it per-Feature. Rejected: the toggle-cleanup case isn't an exception needing an override, it's the normal shape of a Feature — making it the common path required an `AskUserQuestion` almost every time, which is worse than not having a gate.
- Encode the checklist via `markdownToAdf` learning GFM `- [ ]` syntax generically. Rejected: ADF `taskItem` content is plain inline text only (no headings, code blocks, multiple paragraphs) — teaching the *general* converter about checkboxes would still produce items that can't hold the Known Issue detail we need, and risks corrupting unrelated documents that happen to start a line with `-`. A purpose-built tool that assembles prose + a real task list from structured input avoids both problems.
- Naming the new tool something operation-shaped like `update_comment`. Rejected per explicit direction: tools here are workflow-specific, not operation-specific — `post_feature_review_checklist` names the workflow it serves, matching `update_acceptance_criteria`'s naming, not the underlying REST verb.
- Having `feature_review_synthesis` call `update_issue` to add ticket-update commentary. Rejected: `update_issue` is for changing structured fields and requires a "show the user, get explicit OK on the audit_comment text" ceremony we'd be re-implementing badly inside an agent; `feature_review_ticket_update` just posts a plain comment via `add_comment`, and the OK already happened at the interactive ticket-action step.
- A hard requirement that resolved items always get marked `done` automatically. Rejected: cross-run matching is best-effort (title similarity, not exact), so `feature_review_synthesis` is instructed to leave an item `todo` rather than guess it's resolved when it can't confirm that confidently.

**Why.** The gate removal and the real-checklist work came from the same root cause: this review runs repeatedly over a Feature's life, not once at a clean finish line, so the design needs to treat "still in progress" and "reviewed before" as normal cases, not edge cases.

**Revisit if.** (1) `get_issue`'s comment field ever exposes pagination controls — right now `feature_review_fetch`'s prior-review detection is best-effort against whatever page Jira returns by default, and a heavily-discussed Feature could theoretically have an old review comment fall outside that window. (2) A second workflow wants a persistent checklist comment — `post_feature_review_checklist` is scoped to this one for now (YAGNI), per the "workflow-specific" naming; generalize only when there's a second real consumer.

---

## 2026-08-03 — Feature review headless/auto: opt-in ticket actions, a comment-patch step, and mode-aware blocker handling

**Decision.** Four pieces, settled together in a design discussion before implementation:

1. **`create_tickets` is an explicit opt-in flag**, parsed by `SKILL.md` alongside the mode keyword (e.g. `/code-review MDP-236636 headless create-tickets`). Absent by default — auto/headless never touch tickets unless this is passed. When passed, Step 7 applies the same routing interactive mode would (an existing open ticket named in `Tracked by:` gets updated; otherwise a new one is created) to *every* Known Issue uniformly, with no per-item selection, since there's no one to ask. New tickets are always type Story — no severity-based heuristic to guess Bug vs. Story, because a wrong automated guess is worse than the one safe default a human can retype later.
2. **A new Step 7.5 patches the already-posted Feature comment** after Step 7 runs. Step 6 posts before Step 7 acts on any ticket, so a Known Issue's `Tracked by: none` goes stale the moment Step 7 creates or references a ticket for it. Step 7.5 is one batched partial update (via `post_feature_review_checklist`, using `local_id`s from `review_history.md`) covering every item Step 7 touched — proven safe by the live-verified guarantee that a partial update never reorders or disturbs items it wasn't told about.
3. **Auto and headless diverge on blocker handling, not on routine pausing.** Both skip every routine `AskUserQuestion`. But auto runs in a developer's own working tree with a user watching, so a hard failure (Step 2's fast-forward, Step 8's stash-pop conflict) just stops with a chat message. Headless is assumed unattended in a fresh checkout, so the same failure goes straight to `headless_escalation.md` Tier 3 (blocker.md, force-commit, push, notify) — skipping Tiers 1-2 entirely, because a fast-forward failure or merge conflict isn't a yes/no decision a reply can resolve, it's hands-on repo work.
4. **The stash-pop conflict blocker documents a real resumability limit**: the stash lives in local git refs, never pushed, so a headless blocker on this specific failure is only resolvable on the same machine — STATE.md makes everything else about the run resumable elsewhere, but not this one thing. Named explicitly rather than silently implying full resumability.

Bundled into the same pass: `orchestrator_instructions.md` (the *branch*-review pipeline, unrelated to any of the above) had never been updated for the four-mode taxonomy — its Mode Behavior section only handled interactive/guided/auto, with no headless case at all. This matters because `/develop`'s Step 10 reads this file directly and passes through whatever mode `/develop` is running in, including headless — so a headless `/develop` run reaching the Review step had undefined behavior here already, before any of this Feature-review work existed. Fixed by giving headless the same behavior as auto (no judgment call in "which issues are fixable," so no escalation needed) and separately correcting the gate's `AskUserQuestion` option labels, which had drifted from `pipeline_modes.md`'s canonical routine-gate table.

**Rejected alternatives.**
- A severity/category heuristic for auto-picking Bug vs. Story on created tickets. Rejected: adds guessing where a human isn't confirming; "always Story" is the one default a human can trivially correct, and a wrong automatic Bug classification is a worse failure mode than an under-classified Story.
- Having `feature_review_synthesis` own the Step 7.5 patch (a new agent phase) instead of the orchestrator calling the tool directly. Rejected: the patch is small, structured data the orchestrator already has (which ticket, which finding) — no large document parsing needed, so delegating it would add a subagent round-trip for no context-management benefit.
- Escalating Step 2/Step 8 git failures through `headless_escalation.md`'s Tiers 1-2 (resolve from context, or escalate-and-wait). Rejected: neither failure is a question with a yes/no answer — a reply can't fix a merge conflict — so waiting for one would just burn the timeout before landing at Tier 3 anyway.

**Why.** Surfaced by asking, concretely, why headless would ever matter for this skill: for the branch-review path the answer is "it already does, via `/develop`, today" (making the orchestrator_instructions.md gap a real bug, not speculative); for the Feature-review path the answer is "a scheduled or CI-triggered run, not a human typing a command" (making the opt-in ticket-creation flag and the unattended-blocker handling genuinely new design, not a bug fix).

**Revisit if.** A second failure mode needs headless escalation beyond Step 2/Step 8 — re-check whether it's genuinely a Tier-3-only technical failure or an actual Tier-1/2 decision before assuming the same "skip straight to blocker" pattern applies.

---

## 2026-08-03 — `review_instructions.md` moved to `./agents/code_review.md`

**Decision.** The per-ticket review's subagent content — addressed to "you," defines a role, an output format, a git-operations boundary, launched via a general-purpose Agent — lived in `./skills/code-review/review_instructions.md` instead of `./agents/`, violating `instruction_authoring.md` §2 ("every subagent instruction file... even single-use ones"). Its sibling for the fix step, `code_review_fix.md`, already lived in `./agents/` correctly — this was the one file that didn't. No decision-log entry justified it as an intentional exception, so it was drift, not a choice. Moved as-is (content unchanged) to `./agents/code_review.md`, with frontmatter added (`name`, `description`, `model`, `tools`) matching every other agent file. All callers updated: `orchestrator_instructions.md` (2 launch prompts), `feature_review_coverage.md` (2 references to its Pronto/file-type-guideline steps), `advisory_findings.md`, `ARCHITECTURE.md`'s launcher-pattern table.

Bundled into the same pass: `code_review_fix.md`'s "How to fix" section restated `./rules/agent_authoring/code_implementation.md`'s Implementation guidelines almost verbatim — the one code-agent that duplicated instead of referencing it, per §8 "no duplication." Its Reference reads list was also missing `style/replica_reads.md` and `workflows/legacy_code.md`, both on `code_implementation.md`'s universal list and plausibly relevant since this agent edits pre-existing code. Now references the shared rule and carries both reads. Separately, `feature_review_synthesis.md`'s frontmatter granted `Bash` with no use of it anywhere in the body — dropped for least privilege.

**Rejected alternatives.**
- Leaving `review_instructions.md` where it was, on the grounds that it predates the strict §2 convention. Rejected: predating a convention isn't the same as an intentional, logged exception to it — nothing recorded why this file should be different from `code_review_fix.md`.

**Why.** Found via a targeted review of the code-review skill's files against `instruction_authoring.md`'s own conventions — the kind of drift that accumulates silently when a convention tightens after a file was written and nothing re-checks older files against it.

**Revisit if.** A future `/author audit` pass (per `frontmatter_specs.md`'s Agent schema being stale — noted but out of scope here) turns up other files predating a convention tightening; worth checking the rest of `./skills/` for the same pattern rather than assuming this was the only one.

---

## 2026-08-05 — `pipeline_modes.md` stays over the 200-line cap (shared-workspace-sync integration)

**Decision.** `./rules/develop/pipeline_modes.md` grows from 202 to 226 lines while wiring in shared-workspace-sync (`./rules/planning/workspace_sync.md`): a `no_remote_repo_access` pointer, a corrected resume-recovery step, a cleanup precondition, and cross-references. The file was already 2 lines over the cap before this change. Kept as one file rather than split.

**Rejected alternatives.**
- Extract "Workspace cleanup at successful completion" into its own sibling file. Rejected: at ~20 lines it's the only individually-extractable section, and pulling it out would still leave the file over 200 while fragmenting a mode-behavior table away from the other mode-behavior tables it sits alongside (`NEEDS_DECISION behavior by mode`, the new sync-degradation pointer) — worse scannability for a fix that doesn't even close the gap.
- Restate the full `no_remote_repo_access` degradation table here as well as in `workspace_sync.md`. Rejected during this same pass: duplicating the table verbatim across two files violates §8 no-duplication and would have pushed the overage higher, not lower, for no benefit — a one-line pointer to `workspace_sync.md`'s table replaces it.

**Why.** Same reasoning as the 2026-05-20 `instruction_authoring.md` entry: the cap is a soft target, and every line added here is a genuine cross-reference this file's own job (documenting mode behavior) requires — not padding. A forced split would fragment tightly-related mode tables across files for a 13% overage.

**Revisit if.** The file grows meaningfully past 230 lines on a future change — at that point, re-evaluate extracting "Workspace cleanup at successful completion" as a real split rather than a stopgap.

---

## 2026-08-10 — `feature_review_synthesis.md` exceeds the 200-line cap (~230 lines)

**Decision.** Allow `./agents/feature_review_synthesis.md` to run to
~230 lines rather than extract the new Jira comment-splitting procedure
into a sibling file.

**Rejected alternatives.**
- Extract the splitting procedure into its own agent-adjacent file
  (e.g. `feature_review_synthesis_posting.md`). Rejected: the procedure
  is only ever invoked from this agent's own `post_confirmed` phase,
  reads the same in-flight variables (`intro_markdown`,
  `checklist_items`, `closing_markdown`, `review_history.md`), and has no
  second consumer — splitting it would fracture one coherent operation
  across two files for no reader benefit (the "signal of a scope problem"
  caveat in `instruction_authoring.md` §4 doesn't apply here: the agent's
  scope hasn't broadened, one of its existing phases just grew).
- Trim further to hit 200 exactly. Attempted first — cut the length-budget
  section from ~64 to ~40 lines by removing a redundant header repeat and
  merging the two tool-call examples into prose. Further cuts started
  removing the concrete "fits vs. doesn't fit" branching that a
  reader/implementer actually needs.

**Why.** The general Jira-size facts (32,767-char cap, measured markdown→
ADF overhead ratios, the generic splitting pattern) were already
extracted to the new shared rule
`./rules/integrations/jira_comment_limits.md` — that's the
reusable part, and it stayed out of this file. What's left in the agent
file is the agent-specific application of that pattern (exact header
text, which report sections split first, the tool-call sequence) — not
generically reusable, and awkward to read once separated from the phase
it belongs to.

**Revisit if.** A second agent needs the same split-and-post procedure —
at that point extract the *procedure* (not just the underlying facts)
into a shared rule both agents reference.

---

## 2026-08-11 — Sync wiring gap fixed; new cross-ticket read-only pull pattern

**Decision.** Two related fixes to the shared-workspace-sync mechanism
(`./rules/planning/workspace_sync.md`, `run_state.md`), found during
an audit of every `.workspace/`-owning skill (`/develop`, `/planning`,
`/code-review`'s Feature pipeline; `/document` doesn't participate — see
below), plus one new capability:

1. **Wired the push explicitly.** `develop.md`, `fix.md`, `spike.md`
   (`/develop`'s three pipelines) and `planning_instructions.md` each
   restated a partial copy of `run_state.md`'s "After every step
   completes" bullets (move step, bump timestamp, append decisions) and
   silently dropped the fourth bullet — "push the workspace." Grepping
   every `./skills/` and `./agents/` file for the literal
   `sync_workspace_pull`/`sync_workspace_push` tool names turned up zero
   call sites outside `workspace_sync.md` itself and the unrelated
   `/setup` probe (`setup/components/workspace_sync.md`, which syncs a
   throwaway `.setup-check-tmp` path, not a ticket workspace). The four
   restated sections now point at `run_state.md`'s protocol directly
   instead of re-listing (and drifting from) its bullets.
2. **Fixed pull-before-exists-check ordering.** `develop/SKILL.md` Step 3,
   `planning/SKILL.md` Step 3, and `feature_review_instructions.md` Step 0
   all checked "does `.workspace/{key}/STATE.md` exist on local disk"
   *before* ever pulling from the remote — even though `run_state.md`'s
   own "At orchestrator startup" step 0 says the pull must run first
   because it "can be what brings STATE.md down for the first time on
   this machine." As written, a fresh checkout (new machine, or a second
   developer picking up a ticket someone else started planning) would hit
   the "nothing exists → fresh cycle" branch and never see the remote
   in-progress workspace — defeating the cross-developer handoff this
   sync system exists for. All three now pull first, then check.
3. **New: cross-ticket read-only pulls.** `/develop`'s `01_jira.md` now
   pulls a Story's parent Feature's `.workspace/{feature}/` (the
   `/planning` session's own workspace — `codebase_research.md`,
   `tech_design.md`, etc.) as one-time, read-only reference context,
   gated on a new `parent_feature_key` field returned by `jira_fetch.md`.
   Documented generically in `workspace_sync.md` as a variant of the
   existing pattern (same tools, same path construction, different
   ticket's key) with two invariants the default pattern doesn't have:
   never push it back, never delete it during the pulling ticket's own
   workspace cleanup.

**Rejected alternatives.**
- Leave the restated STATE.md-protocol paragraphs alone and just add a
  fourth bullet to each. Rejected: the paragraphs were already a partial
  duplicate of `run_state.md` (violates §8 no-duplication) — patching the
  duplicate perpetuates the drift risk that caused the gap in the first
  place. Pointing at the source once removes the duplication and the bug
  together.
- Treat `parent_feature_key` context as required, blocking Validate/Plan
  until read. Rejected: `planning_brief.md` is explicitly designed so the
  ticket description alone is enough to develop "with ZERO questions" —
  making the pulled Feature workspace load-bearing would contradict that
  design. It's optional background for Validate/Research, never the
  spec of record.
- Have `jira_fetch.md` (a subagent) perform the cross-ticket pull itself.
  Rejected: `workspace_sync.md` already establishes "call the tools
  directly — this is orchestrator-inline logic, not a subagent";
  `jira_fetch.md`'s tool allowlist doesn't include the sync tools for
  the same reason. The subagent returns the key; `01_jira.md` (read
  directly by the orchestrator) performs the pull.

**Why.** Found by grepping every literal `sync_workspace_pull`/
`sync_workspace_push` occurrence in `./` rather than trusting the
rule cross-references — the mechanism was fully specified in
`workspace_sync.md` and cross-referenced by `run_state.md`, but no
orchestrator's own explicit-read instructions ever named
`workspace_sync.md` directly or contained the literal call. Per this
project's own Mode A "explicit read" discipline
(`meta/instruction_authoring.md` §5), a rule reachable only via a
second-hop citation (orchestrator → `run_state.md` → `workspace_sync.md`)
is exactly the "browsing via citation chain" pattern that discipline
exists to prevent. `/document` was confirmed to sit outside all of this
by design — it uses a fixed non-ticket workspace
(`.workspace/document_session/`), which the ticket-validity gate already
excludes; no change was needed there.

**Revisit if.** (1) A second skill wants the cross-ticket read-only pull
pattern (e.g. `/code-review`'s Feature pipeline pulling `/planning`'s
workspace for the same Feature, though today it already gets that
context by owning the same `.workspace/{feature}/` path directly) —
confirm the generic section in `workspace_sync.md` still covers it
before adding a third bespoke consumer. (2) `jira_fetch.md` ever needs to
gate on more than one parent key (e.g. multiple linked Features) — the
single `parent_feature_key` field would need to become a list.

## 2026-08-11 — Self-survey: a fixed reflection question set, piggybacked on workspace_output.md

**Decision.** Added a "self-survey" mechanism: a fixed set of 7 questions
(`./rules/agent_authoring/self_survey_questions.md`) about
instruction quality — conflicts, ambiguity, gaps, prompt-vs-instructions
mismatches, YARD/`docs/features/` usage, MCP tool problems — that a
subagent answers once, right before it returns, writing to
`[workspace]/self_survey/{timestamp}_{agent}.md`
(`./rules/agent_authoring/self_survey.md` has the full mechanics:
frontmatter with a `reviewed: false` placeholder field, secrets/PII
handling, the ticket-validity gate). Wired in by piggybacking on the
existing shared return pattern rather than editing every agent file
individually:

- One line added to `workspace_output.md`'s numbered steps — covers the
  23 agents that already reference it.
- One line added to `code_implementation.md`'s Output Format section —
  covers the 5 agents that reference *it* instead
  (`code_business_logic`, `code_api`, `code_ui`, `code_background_job`,
  `code_review_fix`).
- Individual lines in `architecture.md` and `design.md` (neither
  references a shared output-format file).
- `code_review.md` needed one more piece: it never received a
  `workspace:` input at all (the orchestrator writes
  `[workspace]/code_review.md` itself, after the agent returns full
  findings directly) — so `orchestrator_instructions.md`'s two launch
  prompts now pass `Workspace: [path, if provided]` through, and
  `code_review.md` answers the survey only when that's present (a
  standalone `/code-review` with no ticket has nowhere to write it).

Net: 31 of 36 agent files covered. The 5 left out
(`feature_review_ticket_update`, `planning_jira_create`, `report_issue`,
`setup_check`, `workspace_sync_resolve`) are narrow, single-purpose
agents (post one comment, create one ticket, log an issue, check setup,
resolve a sync conflict) where a 7-question reflective survey adds
little.

No trigger/schedule needed: since every orchestrator now pushes the
workspace after every step (per the same-day sync-wiring fix above), a
survey file written before a subagent returns rides along on the very
next push automatically.

**Rejected alternatives.**
- Add the survey step to every agent file individually. Rejected:
  23 of the 31 covered files needed zero direct edits by finding the two
  existing shared choke points (`workspace_output.md`,
  `code_implementation.md`) instead — same outcome, far less
  duplication, and any future agent that adopts either shared pattern
  gets the survey for free.
- Orchestrator answers one combined survey at the end of the pipeline
  instead of each subagent individually. Rejected: the subagent that
  just finished a step has the freshest, most specific view of which
  rule file it found ambiguous; the orchestrator only sees each
  subagent's terse summary return, not its internal reasoning, so an
  orchestrator-only survey would mostly reproduce information already
  lost by the time it answers.
- Route answers through the existing `report_issue.md` /
  `.workspace/issue_log.md` mechanism instead of a new file. Rejected:
  that log is explicitly local-only and event-triggered (a correction,
  an unexpected failure, a `NEEDS_DECISION` revealing a gap) — deliberately
  never synced (see the 2026-05-21 entry on `issue_log.md`). The
  self-survey is the opposite shape: routine, fixed-question, and
  *meant* to travel via the already-working shared-workspace-sync so
  answers aggregate somewhere central without waiting on the
  GitHub-Issues integration that entry describes as still pending.
- A single growing survey file per ticket instead of one file per
  subagent run. Rejected: a shared file means every subagent would need
  to read-modify-write it, risking a race or a clobbered answer if two
  steps ever overlap; one timestamped file per run needs no
  coordination and makes each answer independently reviewable.

**Why.** The user recalled a similar feature existing previously; a
history search (`git log --all -S"survey"`) timed out on this
repository's full history and turned up nothing conclusive either way —
plausibly something from the pre-migration `docs/agents/` era that
didn't survive the May 2026 fold into `./rules/`/`./agents/`
(no decision-log entry documents it either way). Rebuilt fresh here
rather than trying to recover un-findable prior art.

**Revisit if.** (1) The `reviewed: false` field ever gets a real
consumer (a `/self-survey-review`-style skill) — decide then whether it
becomes a per-item or per-file flag. (2) One of the 5 excluded agents
turns out to hit real instruction friction worth capturing — add it
individually rather than lowering the bar for all narrow agents. (3) The
per-subagent file count becomes unwieldy for a single ticket (e.g. a
13-step `/develop` run produces 13 survey files) — consider a
lightweight index or consolidation pass, but only once real usage shows
it's needed.

## 2026-08-11 — Line-count audit: two mechanical splits, three logged exceptions

**Decision.** Reviewed 5 files flagged over the ~200-line cap with no
decision-log entry (the other 3 over-cap files at the time,
`pipeline_modes.md`, `instruction_authoring.md`,
`feature_review_synthesis.md`, already had entries and needed no
action). Two got mechanical splits; three are logged as accepted minor
exceptions.

**Split:**
- `develop/pipelines/develop.md` (290 → 213). Every numbered step
  already delegated to `steps/NN_*.md` (9 precedents); two sections
  never got that treatment. Extracted **"Plan Review & Q&A gate"** to
  `steps/plan_review_gate.md` and **"Documentation (after Code)"** to
  `steps/documentation.md`, leaving 2-line pointers — same pattern as
  the existing 9. The 213 remainder (`General rules`, `Progress
  reporting`) has no comparable clean boundary; logged as accepted
  below rather than split further.
- `develop/SKILL.md` (239 → 206). Extracted **"Issue reporting"** (a
  self-contained conditional side-behavior, not part of the core step
  flow) to `./skills/develop/issue_reporting.md`, per
  `instruction_authoring.md`'s own layered-separation table
  ("Skill-only conditional content" → `./skills/<skill>/<anything>.md`).
  The 206 remainder is core startup/dispatch logic
  (ticket resolution, resume check, ticket_type, dispatch) that's
  tightly coupled — extracting it would fragment one coherent
  procedure, so it's logged as accepted below.

**Logged as accepted (no clean boundary, or trivially small):**
- `planning/planning_instructions.md` (210, +10). Read in full — every
  step is already a short paragraph delegating to an agent file; no
  restated/duplicated chunk to lift out. The closest candidates (Error
  Handling ~13 lines, Important Notes ~6 lines) are too small
  individually to justify a new file.
- `./agents/code_review.md` (205, +5) and
  `code-review/feature_review_instructions.md` (204, +4) — both grew
  past 200 for the first time from this same day's earlier sync-wiring
  and self-survey additions (see the two entries directly above this
  one); the overage is incidental to a real functional change, not
  accumulated bloat.

**Rejected alternatives.**
- Split `planning_instructions.md` anyway to close the 10-line gap.
  Rejected: §4 explicitly warns against splitting "to make line counts
  pretty" when there's no clean conceptual boundary — forcing one here
  would fragment a file that's otherwise a model of the "thin,
  delegating" pattern this whole audit is trying to encourage elsewhere.
- Chase `develop.md`/`develop/SKILL.md` all the way down to exactly 200
  by extracting a third, smaller section from each (`Progress
  reporting`, or parts of `Setup`). Rejected for the same reason — both
  remainders are either general cross-cutting rules or tightly-coupled
  startup sequence, not extractable without harming comprehension.

**Why.** The user ran a line-count check against the ~200-line soft cap
and asked for an assessment before deciding what to fix. Splitting
`develop.md`/`SKILL.md` was clearly justified: both had an obvious,
previously-unapplied instance of a pattern the file *itself* already
uses repeatedly. The other three didn't have that signal, so forcing a
split would have been the anti-pattern §4 warns about, not a genuine
fix.

**Aside, not acted on.** `ARCHITECTURE.md`'s "launcher pattern" section
describes `SKILL.md` files as thin ~30-80 line launchers.
`develop/SKILL.md` is at 206 even after this split — far from that
target, unlike its siblings (`code-review/SKILL.md` at 80,
`planning/SKILL.md` at 107). Bringing it down to that range would mean
moving its Setup/dispatch logic into a new orchestrator-reads file, a
materially bigger restructuring than this pass's scope. Not done here;
flagged for a future pass if desired.

**Revisit if.** (1) `planning_instructions.md` grows past ~220 —
re-check for a real boundary once there's more content to work with.
(2) The `develop/SKILL.md` vs. `ARCHITECTURE.md`'s 30-80 line target gap
becomes a real problem (e.g., context pressure traced back to
`/develop`'s launcher size) — revisit the aside above as its own pass.

## 2026-08-12 — `MdExcludes` to fix unconditional-load bloat; Mode A's assumption was wrong

**Decision.** A developer reported (via `/context`) that "Memory files"
consumed 158-174k tokens (~17%) of every session, team-wide, and asked
whether that was accurate and fixable. Investigation (confirmed against
[code..com/docs/en/memory](https://code..com/docs/en/memory)
and [code..com/docs/en/sub-agents](https://code..com/docs/en/sub-agents),
not just inference) found:

1. **Every `.md` file under `./rules/` without a `paths:` field
   loads unconditionally into every session — including this project's
   entire "Mode A" set (~119 of 123 files).** Mode A was designed on the
   assumption that lacking `paths:` meant "explicit read only, not
   auto-loaded." That assumption is false.  Code has exactly two
   states: has `paths:` (conditional) or doesn't (unconditional). Mode A
   and Mode B are frontmatter-identical from  Code's own point of
   view.
2. **This is not paid once per session — it's paid by every subagent
   too.** Per the sub-agents doc: "A non-fork subagent's initial context
   contains... every level of the .md hierarchy the main
   conversation loads, including... project rules... The built-in
   Explore and Plan agents skip this." Every custom agent this project
   defines is launched as `general-purpose`, not as `Explore`/`Plan`, so
   none get that exemption. A `/develop` run launching ~15-20 subagents
   pays this cost that many times over, not once.
3. **The fix is `MdExcludes`** (`./settings.json`, any
   settings layer including `project` — i.e., checked into the repo,
   applies to the whole team), a glob-pattern exclude list Anthropic
   documents with an example that directly excludes a `./rules/**`
   path. This requires zero file moves and zero citation updates —
   every existing explicit `Read`/citation of an excluded file keeps
   working exactly as before; only the *automatic* pre-load is
   suppressed.

**Applied (verified via `/context` before/after each step, fresh
sessions, both VS Code and RubyMine to rule out an IDE-specific quirk):**
- Excluded `meta/decision_log.md` alone first, as a cheap validation:
  174.5k → 147.6k (−26.9k, matching its 26.8k size almost exactly).
- Excluded the rest of the "no natural code-path binding" cluster —
  `meta/{instruction_authoring,content_discipline,README}.md`,
  `agent_authoring/`, `develop/`, `planning/`, `workflows/`,
  `troubleshooting/`, `jira/`, `git/`, `integrations/`, `code_review/`,
  `documentation/` (all confirmed to contain zero `universal: true`
  files first) — 147.6k → 68.7k. **Total: 174.5k → 68.7k, a 60%
  reduction**, using only settings-level exclusion.
- Added `./skills/author/pipelines/audit.md` Check 5
  ("Unconditional-load hygiene") so a future rule file added without
  `paths:` and without a `MdExcludes` entry gets flagged, instead
  of silently reintroducing this exact problem.

**Deliberately not excluded:**
- The 4 `universal: true` files (`communication.md`,
  `meta/frontmatter_specs.md`, `meta/cross_references.md`,
  `architecture/code_placement.md`) — unconditional loading is their
  intended behavior.
- `LOCAL.md` — personal, gitignored, per-developer; not part of the
  team-wide compounding problem, and its content (e.g. commit-tag
  conventions) is meant to be always-active without an explicit read.
- `style/`, `security/`, `design/`, `architecture/`, `testing/`,
  `yard/` — these correspond to real code areas and are better served
  by genuine `paths:` scoping (Mode C, conditional load only when
   touches matching files) than blanket exclusion. Tracked as a
  separate, judgment-heavy follow-up pass, not bundled into this one.

**Rejected alternatives.**
- Physically relocating ~40 files out of `./rules/` to a new,
  non-scanned directory. This was the first plan discussed, before
  `MdExcludes` was found — rejected once found, because it
  requires updating every citation across every agent/skill file that
  references the old path (real mechanical risk, no functional
  benefit over the settings-level fix), whereas `MdExcludes`
  achieves the identical outcome with zero citation changes.
- Trusting a subagent's self-report about its own context contents to
  determine whether subagents are affected. Two independent probe
  subagents gave *contradictory* self-reports (one claimed to have
  "every listed `./rules/**` file" while denying one specific
  file within that set; a second flatly denied having a file it should
  have had per the docs). Self-report was demonstrably unreliable in
  both directions; the official sub-agents doc settled it.

**Why.** Confirmed empirically (not just per the docs) via live
`/context` screenshots at each step, on the actual token numbers, in
two different IDEs. The size of the win (60% reduction, zero risk to
existing citations) justified doing this ahead of the harder
`paths:`-scoping pass.

**Revisit if.** (1) The `style`/`security`/`design`/`architecture`/
`testing`/`yard` `paths:`-scoping pass lands — re-verify the total drops
further and update Check 5's "known backlog" note in `audit.md`.
(2) Anthropic ships a documented per-file "never auto-load" frontmatter
field (distinct from `paths:` or `MdExcludes`) — reconsider
whether that's cleaner than settings-level exclusion.
(3) `instruction_authoring.md`'s Mode A/B/C definitions get corrected to
reflect the finding above (still pending — Mode A's own description
currently still says nothing about needing `MdExcludes` to avoid
unconditional load).

## 2026-08-12 — `paths:` scoping for the domain-specific rule folders (follow-up to the `MdExcludes` entry above)

**Decision.** Completed the deferred half of the unconditional-load fix:
added genuine `paths:` frontmatter to the 48 files in
`style/`, `security/`, `design/`, `architecture/`, `testing/`, `yard/`
that correspond to a real code area, so they load only when 
actually reads a matching file (Mode C) instead of unconditionally
(Mode A) or being blanket-excluded (which would have made them
unavailable even when genuinely relevant). The remaining 11 files in
those same folders are pure navigation/orientation content with no
sensible per-file glob (`README.md` indexes, `system_overview.md`,
`deployment.md`, and the two `feature_toggle*.md` files, which are
already explicitly cited from `code_implementation.md` whenever a
toggle strategy applies) — added to `MdExcludes` instead, same
treatment as the rest of the `README.md`/orientation files excluded in
the entry above.

Broad, genuinely-Ruby-wide rules (`style/essentials.md`,
`style/ruby.md`, `style/naming.md`, `design/solid.md`,
`design/principles.md`, `design/anti_patterns.md`,
`design/refactoring.md`, `design/testability_signals.md`,
`security/overview.md`, `architecture/naming_conventions.md`,
`yard/authoring.md`) got `paths: ["**/*.rb"]` rather than being marked
`universal: true`. This is deliberately narrower than universal: a
session that never reads or writes a `.rb` file (a pure Jira-only
conversation, a `/github` MR-status check, a docs-only ticket) never
loads them at all, whereas marking them universal would load them
unconditionally regardless.

**Result:** all `./rules/` files are now accounted for under one
of three states — 4 `universal: true` (deliberate), 49 `paths:`-scoped
(48 new + `yard/cross_references.md`'s existing false-positive-turned-real
entry), 25 `MdExcludes` entries (14 from the prior entry + 11
here), 0 remaining bare Mode-A-with-no-safeguard files. `audit.md`
Check 5's temporary "known backlog" note (added in the prior entry) is
removed now that the backlog is cleared.

**Minor side effect.** `security/business_logic.md` crossed the 200-line
cap by 1 line (201/200) purely from the added frontmatter block. Not
worth restructuring for one line; logged here per the existing
line-count-exception convention rather than given its own entry.

**Rejected alternatives.**
- Marking the broad `**/*.rb`-scoped files `universal: true` instead of
  giving them a glob. Rejected: universal loads regardless of session
  type; `paths: ["**/*.rb"]` achieves the same effective coverage for
  every code-writing session while genuinely saving the tokens for
  session types that never touch Ruby at all — strictly better, no
  downside.
- Excluding `feature_toggle.md`/`feature_toggle_cleanup.md` from the
  rules tree's benefit entirely (treating them as dead weight) instead
  of `MdExcludes`-listing them. Rejected: they're actively used —
  `code_implementation.md` (itself already `MdExcludes`-excluded
  but still explicitly cited by every code agent) tells any agent
  implementing a toggle strategy to read `feature_toggle.md` directly.
  Excluding it from *unconditional* load doesn't touch that explicit
  citation at all; the file remains one Read call away exactly when
  needed.
- Giving `feature_toggle.md` a `paths:` glob instead of excluding it.
  Rejected: toggle checks can legitimately appear in almost any file
  (`app/models/`, `app/controllers/`, route constraints, views) — no
  glob narrower than "everything" would reliably capture where a
  toggle might be added, so a real path scope would either be
  meaningless-broad or miss real cases. The explicit-citation path
  already covers this correctly; forcing it into the `paths:` mechanism
  wouldn't add anything.

**Why.** This was the deferred, judgment-heavy half of the investigation
in the entry above — deferred specifically because assigning globs
needs per-file reasoning about what code area each rule actually
governs, unlike the mechanical, zero-ambiguity exclusion of the
process/meta cluster.

**Revisit if.** (1) A new file is added to any of these 6 directories —
`audit.md` Check 5 now flags it if it lacks both `paths:` and a
`MdExcludes` entry, so this shouldn't silently regress. (2) The
`**/*.rb` scope proves too broad in practice (e.g., loads for sessions
that touch one incidental `.rb` file but never need style guidance) —
consider narrowing further, though the docs indicate this only fires
on an actual file *read*, not a broader trigger.

## 2026-08-13 — Subagent-side verification of the `MdExcludes`/`paths:` fix (closes the open item from the two entries above)

**Decision.** Directly verified, via behavioral testing rather than
self-report, that both halves of the memory-loading fix work correctly
for subagents — not just the top-level session already confirmed via
`/context`.

**Method.** Self-report ("do you have X loaded?") was already known
unreliable from earlier probes in this same investigation (one
subagent claimed to have "every listed rules file" while denying one
specific file within that set — internally contradictory). So this
test instead asked a subagent to (1) read a file matching one of the
new `paths:` globs (`app/models/bounce_receiver.rb`), then (2) produce
verbatim quotes it could only reproduce accurately if the content were
genuinely present — a positive control (`architecture/sharding.md`,
which should load) and a negative control (`meta/decision_log.md`,
which should not) — with explicit instructions to say "I don't have
this" rather than approximate.

**First attempt was confounded and correctly flagged as such before
trusting it.** A subagent launched *from the long-running working
session used for this whole investigation* correctly quoted
`sharding.md` (paths: scoping worked) but also correctly-verbatim
quoted `decision_log.md` (which should have been excluded). Rather than
conclude the fix was broken, this was recognized as the same
session-start-freezing artifact already identified for the top-level
session earlier in this file: that working session began before the
`MdExcludes` settings existed, and — per
[code..com/docs/en/sub-agents](https://code..com/docs/en/sub-agents)
— a subagent inherits the .md hierarchy "the main conversation
loads," which for a stale session means the stale, pre-fix snapshot.

**Second attempt, from a genuinely fresh session, resolved it
cleanly.** Same test, new session started after all the fix commits:
`sharding.md` quote matched exactly; `decision_log.md` correctly came
back "I don't have this in my context" — and the subagent volunteered,
unprompted, that the only `meta/` files present were
`frontmatter_specs.md` and `cross_references.md`, exactly the two
`universal: true` files in that folder. Both halves of the fix — path
scoping firing on read, and exclusion holding for non-universal
files — confirmed for subagents, not just the top-level session.

**Why this mattered enough to chase down.** The two entries above
established the mechanism from official documentation and verified it
for the top-level session; subagent behavior was inferred from the
docs' wording, not independently tested. Given `/develop` launches
15-20 subagents per ticket, an unverified assumption here would have
been the highest-leverage place for this whole fix to quietly not
work — worth the extra round of testing to close.

**Revisit if.** A future change to `MdExcludes` or the `paths:`
list should ideally get one subagent-side spot-check like this, from a
fresh session, rather than trusting `/context` (top-level-only) alone.

## 2026-08-13 — `/author` pipelines updated to prevent the unconditional-load bug from recurring

**Decision.** The four entries above fixed the *existing* unconditional-load
problem and corrected the *conceptual* documentation (`instruction_authoring.md`,
`frontmatter_specs.md`) and the *audit* check (`audit.md` Check 5). One layer
was still missing: the actual authoring workflow. As written before this
entry, `/author create rule` would ask "Loading mode — Mode A (explicit
read, default)..." and stop there — a brand-new Mode A rule created today
would have gotten frontmatter identical to the ~119 files that caused the
whole problem, with nothing prompting a `MdExcludes` entry. Audit
Check 5 would eventually catch it on a future `/author audit` run, but
"eventually caught by audit" is strictly worse than "can't be created wrong
in the first place."

**Applied.**
- `create_rule.md` Step 2: reframed the loading-mode question around the
  actual mechanism (does a real path binding exist? → Mode C; applies to
  literally every session? → Mode B; otherwise → Mode A, which now
  explicitly states it requires a `MdExcludes` entry). Mode C
  guidance now says to verify globs with `Glob` against real files, not
  just "confirm they cover the actual code locations" in the abstract.
- `create_rule.md`: replaced the Mode-B-only "add a decision-log entry"
  step with a "sync loading-mode side effects" step covering all three
  modes (Mode A → `MdExcludes`; Mode B → decision log; Mode C →
  nothing needed) so the instruction can't be read as "only Mode B has a
  required follow-up."
- `create_rule.md` Step 6 and the final report: added a `MdExcludes`
  coverage check and reporting line, so it's confirmed before the pipeline
  finishes, not left for a later audit.
- `update.md`: added handling for a rule's loading mode changing mid-edit
  — moving to Mode A requires adding the exclude entry, moving away from
  it requires removing the stale one — plus a matching convention check,
  report line, and failure mode ("fix it before finishing, don't just
  flag it").
- `SKILL.md`: added "Unconditional-load drift" to the failure-modes list,
  alongside the existing universal-rule-creep and cross-reference-rot
  entries it already tracked.
- `audit.md`: added a failure-mode note that verifying a Check 5 fix via
  `/context` requires a *fresh* session — checking in an already-running
  session (this investigation hit that exact confusion twice, once for
  the top-level session and once for a subagent) shows stale numbers and
  isn't evidence of failure.

**Rejected alternatives.**
- Leaving this to `/author audit` alone. Rejected: audit is a detection
  net, not a prevention mechanism — by the time it runs, the bad rule
  file has already been loading unconditionally for however long it took
  someone to run a full audit. Fixing the creation/update pipelines
  closes the gap at the only point that actually prevents the cost from
  being paid at all.
- Adding a new, separate `/author create-rule --check-loading-mode` flag
  or sub-step instead of folding it into the existing question flow.
  Rejected: the loading-mode question already existed in Step 2; the fix
  was to make the existing question ask the right thing and have a
  required consequence, not to add new surface area.

**Why.** `create_rule.md` and `update.md` are literally the two places
new content enters `./rules/` under normal operation. Any fix that
doesn't touch them leaves the door open for the next rule file — created
by a human or by an unrelated `/author` session with no memory of this
investigation — to reintroduce the same cost from scratch.

**Revisit if.** A future  Code release adds a real "never
auto-load" frontmatter field (distinct from `paths:` and
`MdExcludes`) — simplify these pipelines to use it directly instead
of the two-file (frontmatter + settings.json) dance.

## 2026-08-18 — Shared `STATE.md` split into `CONTEXT.md` + per-skill `STATE_<skill>.md`

**Decision.** Replace the single `[workspace]/STATE.md` (one file per
ticket, shared across every skill, with top-level `skill:`/`mode:`/
`completed_steps:`/`pending_steps:`/`skipped_steps:` fields that got
overwritten whenever a different skill wrote it) with two kinds of file:
`[workspace]/CONTEXT.md` (cross-skill shared carry-forward — `recent_decisions`,
`last_known_comments`, `last_known_discussions`, `notes` — append-only,
never overwritten) and one `[workspace]/STATE_<skill>.md` per skill that has
run on the ticket, owned exclusively by that skill. Full schema in
`./rules/planning/run_state.md`.

Bundled into the same change: completed steps are no longer trusted by
blind presence in `completed_steps`. A new agent,
`./agents/resume_verify.md`, is launched once per resume, covering
every completed step plus any pending/absent step whose expected output
file already exists on disk. It decides per step — leaning "no" by
default, using `completed_at` recency plus a
`git log --grep='\b<TICKET_KEY>\b'` check (word-boundary anchored, so
`MDP-1234` doesn't also match `MDP-12345`) for relevant activity since —
whether to read the actual output and
spot-check it, then returns `trusted` / `flagged` (annotate in place) /
`reset` (move the step back to `pending_steps` in `STATE_<skill>.md`). It
never regenerates content itself — that stays the job of the step's own
agent, re-run normally once reset.

**Rejected alternatives.**
- Leave `STATE.md` as a single shared file and just rename it. Rejected:
  the naming wasn't the problem — a flat, single-owner-at-a-time file
  cannot represent "multiple skills each need their own independently
  resumable progress on the same ticket, in any interleaving, any number
  of times" no matter what it's called.
- Nest per-skill step-tracking inside one `STATE.md` (`skills: {develop:
  {...}, planning: {...}}`) instead of splitting into separate files.
  Rejected: this codebase's workspace files are already plain-text,
  append/read by convention rather than a real parser; nested structure
  raises the risk of one skill's naive text-based write clobbering a
  sibling skill's block. Separate files make single ownership physically
  enforced rather than a convention to remember.
- A hardcoded staleness threshold (e.g. "trust if completed within 7
  days") for the resume trust check. Rejected per explicit direction: the
  right signal is relevant activity since completion (commits tagged with
  the ticket key), not raw elapsed time — a step untouched for six months
  on a ticket with zero activity since is still trustworthy, and a step
  from yesterday on a ticket with a same-day commit touching what it
  describes is not.
- Folding the trust/verify judgment into `run_state.md` as prose the
  orchestrator interprets inline. Rejected: deciding what to check, how
  deep to check, and how to remediate a finding (flag vs. reset) is
  judgment work of the same kind `research.md`/`document_yard.md` already
  do as subagents, not something to encode as static rule-file text.

**Why.** Surfaced while designing the new `/research` skill: its core
value (durable research reused later by `/develop`, or vice versa) depends
on a skill's own resume record surviving other skills touching the same
ticket in between — which the single-`STATE.md` design explicitly did not
guarantee (the "After every step completes" protocol only preserved
`recent_decisions:`/`notes:`/comment-tracking across a skill handoff, not
step-tracking). The user's own usage pattern
(`planning → planning → develop → research → develop → code-review →
develop → research → code-review`) made the gap concrete: any of those
skills resuming after another skill's turn would have its own
`completed_steps` silently reset by the intervening skill's write.

**Revisit if.** The number of skills sharing one ticket's workspace grows
large enough that `STATE_<skill>.md` file count becomes unwieldy (no
concrete threshold yet — revisit if it ever feels like it, not
preemptively). Or if `resume_verify.md`'s commit-grep heuristic proves too
coarse in practice even with word-boundary anchoring (e.g. a commit that
genuinely, exactly mentions the ticket key but is semantically unrelated
to the step being checked) — the next refinement would scope the
`git log` check to paths the step's output actually references, not just
ticket-key presence in the message.

## 2026-08-18 — `/code-review`'s ticket-key dispatch was Feature-only; added Story/Bug/Task routing

**Decision.** `SKILL.md` Step 0 treated *any* ticket-key-shaped argument
as a Feature-level review, unconditionally. Passing a Story/Bug/Task key
(e.g. `/code-review MDP-230574` on a Bug) fell into
`feature_review_fetch`, which correctly rejected it as `NOT_A_FEATURE`,
but nothing routed it anywhere useful — there was no standalone way to
get a ticket-context-aware review by ticket key; that context-passing
only existed inline, from `/develop` Step 10. Changed Step 0 to fetch the
ticket's `issuetype` first (a direct `mcp__jira__get_issue` call, no
subagent — same pattern `./skills/jira/SKILL.md` already uses,
avoiding a redundant fetch on the Feature path where
`feature_review_fetch` re-fetches anyway) and dispatch three ways:
`Feature` → the existing Feature-review pipeline (unchanged); `Story` /
`Bug` / `Task` → the existing branch-review pipeline
(`orchestrator_instructions.md`), now fed this ticket's
requirements/`acceptance_criteria` from the same fetch as ticket context
— reusing `orchestrator_instructions.md` Step 2's and
`review_criteria.md`'s existing "ticket context was provided" handling,
the same mechanism `/develop` Step 10 already relies on; anything else
(Spike, DevOps Request) → a clear "no pipeline covers that type" message
pointing at standalone `/code-review` or `/develop ... fix`.

**Rejected alternatives.**
- Launching `jira_context_fetch` (the new read-only fetch agent shared by
  `/planning` and `/research`) instead of a direct `get_issue` call.
  Rejected: it writes its output to a workspace file, which the
  branch-review pipeline doesn't otherwise use at all when invoked
  standalone (no `/develop` workspace exists) — adopting a workspace just
  for one ticket's description/AC would add file-lifecycle concerns
  (`run_state.md` STATE conventions, sync pull/push) for data that fits
  in a few lines of inline context, which is exactly the shape
  `orchestrator_instructions.md`'s prompt template already expects.
- Restricting the new path to Story/Bug only, matching the Feature-review
  pipeline's existing commit-coverage gating (which only requires
  coverage for Story/Bug children). Rejected: `jira_context_fetch.md`
  already treats Task as AC-bearing alongside Story/Bug (extracts
  `acceptance_criteria` for all three, skips it for Feature/Spike) — that
  existing type grouping is the more relevant precedent for "does this
  ticket carry requirements a branch can be checked against," not the
  Feature pipeline's separate commit-gating logic.
- Having `feature_review_fetch` itself redirect non-Feature tickets to
  the new path, instead of checking type before launching either
  pipeline. Rejected: that would launch a full Feature-oriented fetch
  (children, prior review comments, planning artifacts) just to learn the
  ticket isn't a Feature, then need a second fetch anyway for the
  Story/Bug/Task path's requirements/AC — checking type first avoids the
  wasted work.

**Why.** Surfaced by real usage: a user ran `/code-review MDP-230574` (a
Bug) expecting *some* useful review and got routed straight into the
Feature-only error path with no fallback, even though the underlying
machinery for a ticket-context review already existed and was already
exercised daily via `/develop` Step 10 — it just had no standalone entry
point reachable by ticket key.

**Revisit if.** A second Jira ticket type turns out to carry AC/code in
this codebase's convention (would extend the Story/Bug/Task list); or the
Feature path's redundant fetch (once via Step 0's type check, again via
`feature_review_fetch`) becomes a measurable cost worth restructuring
around.

---

## Template for new entries

```markdown
## YYYY-MM-DD — <short title>

**Decision.** <one or two sentences>

**Rejected alternatives.**
- <option> (<why rejected>)
- <option> (<why rejected>)

**Why.** <full reasoning, including the failure mode that pushed us here>

**Revisit if.** <conditions that would make us reconsider>
```
