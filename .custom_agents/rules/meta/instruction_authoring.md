---
last_reviewed: 2026-05-19
---

# Authoring Skills, Agents, and Rules

Canonical conventions for the AI-instruction layer. Every convention has a **Rule** and a **Why** so future maintenance can judge edge cases.

When in doubt while authoring an instruction file, invoke the `/author` skill — it enforces these conventions and updates the decision log when an override is recorded.

---

## 1. Layered separation

**Rule.** Three layers, three locations. No instruction file lives outside this map.

| File contains | Location |
|---|---|
| A skill orchestrator (the entry for `/<name>`) | `./skills/<skill>/SKILL.md` |
| Skill-only conditional content | `./skills/<skill>/<anything>.md` |
| A subagent's instructions | `./agents/<name>.md` (always — even if only one skill uses it) |
| A shared rule, used by multiple skills/agents | `./rules/<topic>/<subtopic>.md` |
| A topic index for a rules folder | `./rules/<topic>/README.md` |
| Project entry for  Code | `/.md` |
| Project entry for non- agents | `/AGENTS.md` |
| Per-task workspace | `.workspace/<ticket>/` (gitignored) |

**Why.** Without a strict map, instruction files end up everywhere and the context an agent loads becomes unpredictable. The map keeps each kind of content in exactly one place so agents don't have to guess where to look.

---

## 2. Subagents always live in `./agents/`

**Rule.** Every subagent instruction file is in `./agents/<name>.md`. No subagent instructions inline in a skill's pipeline file. No subagent instructions in `./rules/`.

**Why.** Subagents are launched by file path. Centralizing them in one folder makes them discoverable, swappable between skills, and uniformly governed. Inline subagent prompts inside `pipelines/` were the most common reason long pipeline files ballooned.

**How to apply.** When writing a skill that launches a subagent: write the subagent file in `./agents/` *first*, then have the skill reference it. If the subagent is single-use, that's fine — still goes in `./agents/`.

---

## 3. All shared rules live in `./rules/`

**Rule.** Any content that more than one skill or agent reads is a shared rule. It lives in `./rules/<topic>/<subtopic>.md`. Use topic folders generously — `workflows/`, `architecture/`, `style/`, `git/`, `jira/`, `planning/`, `troubleshooting/`, `meta/`, `agent_authoring/`, etc.

**Why.** Without a single home for shared content, duplication slips in. Past inventory found duplication clusters (code-placement repeated in 7 agents, workspace-output pattern in 12 agents, AI co-author trailer in 4 places). Each cluster was a maintenance hazard.

**How to apply.** Before writing a rule, search `./rules/` for similar content. If you find it, extend or extract; don't restate.

---

## 4. ~200-line soft cap on every instruction file

**Rule.** SKILL.md, agent files, rule files: aim for ≤200 lines. When you go over, split.

**Why.** Two reasons. (a) Anthropic's own guidance for .md is <200 lines; we adopt this as a portable target for all instruction files. (b) Above ~200 lines, model adherence drops measurably in long files; splitting by need-to-know preserves attention on the section that's actually relevant.

**How to apply.** Pick the natural seam — usually a section heading — and lift it into a sibling file. The original file references the new file by path. Never split to make line counts pretty; only split where the content has a clean conceptual boundary.

**When to override.** Some content is tightly coupled and splitting harms comprehension. The decision log records overrides. Default is to split.

**Exempt: append-only log files.** Log files like `decision_log.md` grow over time as new entries are appended; splitting them harms historical traceability. These files are exempt from the line cap.

---

## 5. Loading mode —  Code recognizes two states, we track three

**Corrected 2026-08-12 — read this before trusting the term "Mode A" anywhere else in this file.**  Code itself recognizes exactly two states for a `./rules/` file: it has `paths:` frontmatter (loads only when  reads a matching file — in the main session *and* every non-fork subagent), or it doesn't (loads unconditionally, everywhere, always — see [code..com/docs/en/memory](https://code..com/docs/en/memory)). **There is no -Code-native "explicit read only, not auto-loaded" state.** Lacking `paths:` does not mean a file waits to be cited — it means the opposite. This was the exact misunderstanding that let ~119 of this project's 123 rule files load into every session and every subagent unconditionally before it was caught; see `decision_log.md`'s 2026-08-12 entries for the full investigation and fix.

### Mode C — Path-scoped (`paths:`) — prefer this whenever a real binding exists

If a rule corresponds to a real code area (directory, filename pattern, language), give it `paths:`. It's strictly better than the alternative below: zero cost in sessions that never touch matching files, loads automatically with no agent needing to remember to cite it.

```yaml
---
paths:
  - "app/models/**"
  - "components/*/app/models/**"
last_reviewed: 2026-05-19
---
```

A broad-but-real glob (e.g. `**/*.rb` for a Ruby-wide style rule) still beats no glob at all — it costs nothing for sessions that never read Ruby (pure Jira/GitHub/planning work).

### Mode B — Universal (`universal: true`) — small, deliberate, foundational only

Reserved for rules that apply to literally every session regardless of what  reads — not "every code session" (that's Mode C with a broad glob). Add a rule here only when ALL of: it applies without exception to every session; it's small (≤80 lines); the decision log records why. Current set: `communication.md`, `meta/frontmatter_specs.md`, `meta/cross_references.md`, `architecture/code_placement.md`. **Watch:** if this set grows past 3–5 files or 300 lines, audit for content that should be Mode C instead.

### Mode A — Explicit read + `MdExcludes` (for process/meta content with no code binding)

For content with no natural `paths:` binding — agent-authoring patterns, skill-specific process, meta content — the citing agent file enumerates the read, **and** the file is added to `./settings.json`'s `MdExcludes` array. **Both halves are required.** The citation is for humans and for the agent's own understanding; only `MdExcludes` stops  Code from also loading the file unconditionally for every session and subagent that doesn't need it.

```markdown
## Reference reads
- `./rules/agent_authoring/code_implementation.md` — shared code-agent rules
```

```json
{ "MdExcludes": ["**/./rules/agent_authoring/code_implementation.md"] }
```

A directory-wide glob (`**/./rules/<dir>/**`) is fine when every file in that directory is Mode A with no exceptions — check none of them are `universal: true` first, or the glob silently defeats that. `/author audit` Check 5 flags any Mode A file missing its `MdExcludes` half.

---

## 6. Naming conventions

| What | Style | Examples |
|---|---|---|
| Skill folder | lowercase-hyphen-separated | `code-review/`, `agent-testing/` |
| Skill entry file | `SKILL.md` UPPERCASE | `code-review/SKILL.md` |
| Skill supporting file | lowercase snake_case `.md` | `develop/pipelines/develop.md` |
| Agent file | lowercase snake_case `.md` | `report_issue.md`, `planning_research.md` |
| Rule topic folder | lowercase snake_case | `architecture/`, `agent_authoring/` |
| Rule content file | lowercase snake_case `.md` | `code_placement.md`, `branch_naming.md` |
| Folder index | `README.md` UPPERCASE | `./rules/architecture/README.md` |

**Mandatory UPPERCASE exceptions:** `README.md`, `.md`, `AGENTS.md`, `LOCAL.md`, `SKILL.md`, `LICENSE`, `CHANGELOG.md`.

**Skill folder name = slash command.** `./skills/author/` → `/author`. Pick names carefully; rename is expensive.

---

## 7. Frontmatter

See [frontmatter_specs.md](frontmatter_specs.md) for full schemas and examples.

Minimums:

- **Skills** require `name` + `description`. Add `disable-model-invocation: true` for user-only skills.
- **Agents** (those invoked via `Agent(subagent_type=<name>)`) require `name` + `description`.
- **Rules** require `last_reviewed: YYYY-MM-DD`. Add `paths:` only for Mode C (path-scoped) rules.

---

## 8. No duplication

**Rule.** A given fact lives in exactly one file. Other files reference it by path; they do not restate it.

**Why.** Duplication rots. Update one copy, the others go stale, agents read whichever happens to be loaded, and behavior diverges.

**How to apply.** If you find yourself typing the same paragraph (or close to it) into a second file, stop. Extract it to a shared rule and reference both.

**Signal of a scope problem.** If splitting feels like fracturing tightly-coupled content into pieces that don't make sense alone, the subagent's scope is wrong, not the file. Two agents that genuinely need 80% of the same content probably should be one agent.

---

## 9. The decision log

**Rule.** Every non-obvious convention decision gets recorded in [decision_log.md](decision_log.md). One entry per decision: what we picked, what we rejected, why.

**Why.** Without a log, the same trade-offs get re-litigated every six months and conventions drift. With a log, future maintenance has the *reasons* and can judge whether they still apply.

**How to apply.** Add an entry when you (a) make a convention choice not already captured here, or (b) override an existing convention with a documented reason. Don't add an entry for routine work — only for things a future reader would otherwise have to reconstruct.

---

## 10. Content discipline — every sentence costs context

**Rule.** Every sentence in a skill, agent, or rule file should help the reader do its job. Out-of-scope content — especially "don't do X" or "we do Y because Z" for things the agent wasn't already working with — actively hurts by introducing concepts and competing for attention.

**Why.** Agents read instructions to do work. Lines that don't shape the work either get ignored (waste) or get attended to and distort the work (worse). The most common failure mode is well-meaning "don't do X" lines for things the agent had no path toward; naming X plants it in the context.

**How to apply.** See [content_discipline.md](content_discipline.md) for the full framework — when to include WHAT/HOW/WHY/DON'T, with positive and negative examples.

Quick self-check before adding a "don't" or a "because" line:
1. Was the agent already in a position to do X (or aware of Z)?
2. Would it likely make the wrong choice without this line?
3. Does this introduce a concept it wasn't already working with?

If 1 = no, or 3 = yes, leave it out.

---

## 11. Skills ensure `/setup` has run

**Rule.** Every skill ensures `/setup verify` has succeeded for the current session before doing its real work. Skills and agents that need an external CLI tool (ffmpeg, ImageMagick, jq, system libs) assume the tool is available — no presence checks, no install instructions, no per-platform branching.

**Why.** External tool management belongs in one place (`/setup`). Scattering install/check logic across skills creates inconsistency, file bloat, and cross-platform drift. The contract — `/setup` runs first, tools are guaranteed available, the rest of the instruction layer just uses them — keeps skills focused and portable.

**How to apply.**

- A new skill's `SKILL.md` includes a startup step pointing at `/setup verify`. The `/author` skill's template enforces this on creation.
- Skills and agents using external tools simply use them. They do not check `which <tool>`. They do not branch on tool absence.
- New tools get added to `/setup` (not to the skill that uses them). One place to audit.
- Cross-platform support (Linux, WSL) lives only inside `/setup` (via per-OS files like `setup-mac.md`, `setup-linux.md`). The rest of `./` stays portable.

See [`./rules/agent_authoring/external_dependencies.md`](../agent_authoring/external_dependencies.md) for the detailed rule.

---

## 12. Maintenance — use `/author`

**Rule.** Use the `/author` skill to create or update any skill, agent, or rule file. The skill enforces these conventions and will:

- Check the line-count cap.
- Verify frontmatter is present and correct.
- Check for duplication against existing rules.
- Update the decision log if a convention is being overridden.
- Verify cross-references.

**Why.** Hand-authoring is where conventions drift. The skill makes drift a tool failure instead of a memory failure.
