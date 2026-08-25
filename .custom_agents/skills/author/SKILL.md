---
name: author
description: Create or update  skills, agents, and rule files. Enforces the conventions in ./rules/meta/. Use whenever you're authoring or auditing instruction files.
disable-model-invocation: true
---

# `/author` — Skill, Agent, and Rule Authoring

`/author` is the maintenance layer for `./skills/`, `./agents/`, and `./rules/`. It scaffolds new files from templates, enforces conventions when updating existing files, and audits the whole instruction layer for drift.

**Mode.** Detect per [`../../rules/develop/pipeline_modes.md`](../../rules/develop/pipeline_modes.md) (`_CODE_ENTRYPOINT=sdk-cli` → `headless`; otherwise `interactive`). The `audit` sub-mode is fully autonomous and runs in any mode. The `create` and `update` sub-modes need content/decisions and are primarily interactive — in headless mode, only proceed when called with explicit, complete arguments; otherwise emit `state/escalation.json` per the three-tier contract.

The conventions it enforces live in [./rules/meta/instruction_authoring.md](../../rules/meta/instruction_authoring.md). Frontmatter schemas live in [./rules/meta/frontmatter_specs.md](../../rules/meta/frontmatter_specs.md). The decision log lives in [./rules/meta/decision_log.md](../../rules/meta/decision_log.md).

---

## Invocation

`/author` accepts arguments OR runs interactively when none are given.

| Command | What it does |
|---|---|
| `/author` | Prompts: which mode? Then dispatches. |
| `/author create skill <name>` | Scaffold a new skill at `./skills/<name>/`. |
| `/author create agent <name>` | Scaffold a new agent at `./agents/<name>.md`. |
| `/author create rule <topic>/<name>` | Scaffold a new rule at `./rules/<topic>/<name>.md`. |
| `/author update <path>` | Open existing file for edit; apply convention checks after the edit. |
| `/author audit` | Run all four default checks across `./skills/`, `./agents/`, `./rules/`. |
| `/author audit <path>` | Run checks against a single file. |

---

## Dispatch

Parse the arguments and route:

1. **No args** — ask the user via `AskUserQuestion`: which mode (create / update / audit)?
2. **`create skill <name>`** — read [pipelines/create_skill.md](pipelines/create_skill.md). Proceed.
3. **`create agent <name>`** — read [pipelines/create_agent.md](pipelines/create_agent.md). Proceed.
4. **`create rule <topic>/<name>`** — read [pipelines/create_rule.md](pipelines/create_rule.md). Proceed.
5. **`update <path>`** — read [pipelines/update.md](pipelines/update.md). Proceed.
6. **`audit [path]`** — read [pipelines/audit.md](pipelines/audit.md). Proceed.

---

## Universal expectations

Before any dispatch:

1. **Ensure `/setup verify` has succeeded for this session.** If `/setup` hasn't run, run it.
2. Read [./rules/meta/instruction_authoring.md](../../rules/meta/instruction_authoring.md) — the conventions you're enforcing.
3. Read [./rules/meta/content_discipline.md](../../rules/meta/content_discipline.md) — what content belongs in an instruction file.
4. Read [./rules/meta/frontmatter_specs.md](../../rules/meta/frontmatter_specs.md) — the frontmatter shapes.
5. Read [./rules/meta/cross_references.md](../../rules/meta/cross_references.md) — only if the work touches code↔docs links.
6. **`./rules/LOCAL.md` is local-only.** If it exists, treat it as a read-only context input — never copy, paraphrase, or reference its content in the files you author or update. See the "LOCAL.md is local-only" section below.

Do NOT also read the pipeline files for modes you aren't using. Read only the one mode you've dispatched to.

---

## LOCAL.md is local-only

Every developer can have their own `./rules/LOCAL.md` with personal preferences, developer-specific overrides, or per-developer conventions (commit-message tags, role context, custom collaboration rules, project notes specific to that dev). If it exists on a given machine, it applies to **that developer only** — it is gitignored and never travels with the repo.

General skills, agents, and rules do not (and should not) care where their instructions came from. They follow whatever instructions they're given. **`/author` is the exception** — when authoring or updating any skill, agent, or rule, `/author` must keep LOCAL.md content from leaking into the shared instruction tree.

### Rules for `/author`

- **Never copy or paraphrase LOCAL.md content** into committed instruction files (`./skills/`, `./agents/`, `./rules/`, `.md`, `AGENTS.md`).
- **Never reference LOCAL.md examples** (e.g. specific trailer tags, the current developer's role or username, custom phrasing) in committed files. Neutral links like "see LOCAL.md for any project-local conventions" are fine; the *content* of those conventions stays in LOCAL.md.
- **If you discover LOCAL.md-shaped content already in a committed file, flag it as drift.** It leaked from someone's LOCAL.md previously and should be removed (or moved into that developer's LOCAL.md if it's still wanted).
- **`/author audit` watches for this.** Common leakage signals: developer usernames, role titles, specific commit-tag examples, project-local config the developer added for themselves.

Why: committed instruction files apply to *every* developer who uses the repo. LOCAL.md is one developer's personal layer. Mixing them turns one dev's preference into everyone's rule.

---

## What `/author` does NOT do

- Author per-feature documentation in `docs/features/`. That's a separate skill (TBD) and follows different conventions.
- Author Ruby code or migrations. Those use the standard `/develop` workflow.
- Move files between locations. Use `git mv` and update references manually. (Future enhancement: `/author move`.)
- Run the duplication scanner. That's a heavier, opt-in mode (`/author dedup`, TBD).

---

## Failure modes to watch for

- **Convention override without decision-log entry.** If a file genuinely needs to break a convention (e.g. exceed 200 lines), add a decision-log entry explaining why. `/author audit` will flag overrides that lack an entry.
- **Universal rule creep.** When `/author audit` reports the universal set growing past ~300 lines or 5 files, surface it as a finding. Universal rules cost context every session.
- **Cross-reference rot.** Every time a file moves, references break. `/author audit` runs broken-reference checks; treat any new broken ref as a regression.
- **.md / AGENTS.md drift.** The two files are separately maintained but must agree on universal rules. The sync check is in [pipelines/audit.md](pipelines/audit.md).
- **Unconditional-load drift.** A Mode A rule (no `paths:`) with no `MdExcludes` entry loads into every session and every subagent, silently — lacking `paths:` is not "explicit read only" (see `instruction_authoring.md` §5). `create_rule.md` and `update.md` fix this at the source; `audit.md` Check 5 catches anything that slips through.
- **LOCAL.md leakage.** Personal preferences, developer-specific examples, or any other LOCAL.md content showing up in a committed instruction file. See the "LOCAL.md is local-only" section above. `/author audit` should flag these for removal.

---

## When in doubt

- Conventions ambiguous? Re-read [./rules/meta/instruction_authoring.md](../../rules/meta/instruction_authoring.md).
- About to override a convention? Add a decision-log entry first.
- File doesn't fit any of the three locations (`skills/`, `agents/`, `rules/`)? Stop and ask the user — the file may not belong in `./` at all.
