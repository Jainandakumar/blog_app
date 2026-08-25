# Pipeline — Create a New Skill

Scaffolds a new skill at `./skills/<name>/`.

---

## Inputs

From `/author create skill <name>`:
- `<name>` — lowercase-hyphen-separated, becomes both the folder name and the `/<name>` slash command.

If `<name>` is missing, ask the user.

---

## Steps

### 1. Validate the name

- Must be lowercase letters, hyphens, numbers (e.g. `code-review`, not `CodeReview`).
- Must not already exist at `./skills/<name>/`.
- Must not conflict with an existing slash command (check `./skills/` and `./commands/` if it exists).

If validation fails, report the issue and ask for a different name.

### 2. Gather skill details

Ask the user via `AskUserQuestion`:

1. **Description** — one sentence, key use case first. Truncated at 1,536 chars by  Code.
2. **Invocation** — user-only (set `disable-model-invocation: true`), or model can auto-invoke?
3. **Will it launch subagents?** — if yes, list which ones (existing `./agents/<name>.md` references). Capture so the skill's reference reads can be wired in.
4. **Will it have multi-step pipelines?** — if yes, list the modes (e.g. `code-review` has `review` and `fix` modes). One pipeline file per mode.

### 3. Create the folder structure

```text
./skills/<name>/
├── SKILL.md                  # Orchestrator
└── pipelines/                # Only if multi-step modes
    └── <mode>.md             # One per mode
```

### 4. Write `SKILL.md` from the template

Read [./skills/author/templates/skill.md](../templates/skill.md). Fill in:
- `<name>` — the skill name.
- `<description>` — the user's description sentence.
- `<disable-model-invocation>` — `true` or omit.
- Mode dispatch table populated from the user's pipeline list.
- Reference reads — minimum is `[./rules/meta/instruction_authoring.md]` if the skill itself authors anything. Otherwise prune the section.
- **Universal expectations** — keep the `/setup verify` line from the template. Per [./rules/meta/instruction_authoring.md](../../../rules/meta/instruction_authoring.md) §10, every skill enforces the `/setup` contract; do not remove this line.

### 5. Write each pipeline file (if any)

For each mode the user listed, create `pipelines/<mode>.md`. Each pipeline file:
- Names its inputs (what arguments arrive, what context is needed).
- Lists steps numbered 1–N.
- References subagents by full path (`./agents/<name>.md`).
- References rules by full path (`./rules/<topic>/<file>.md`).
- Stays ≤200 lines.

### 6. Run convention checks on the new files

After all files are written:

1. **Line counts** — confirm SKILL.md and each pipeline ≤200 lines.
2. **Frontmatter** — confirm SKILL.md has `name` + `description`. If `disable-model-invocation: true` was chosen, confirm it's present.
3. **Naming** — folder is lowercase-hyphen, files inside are snake_case `.md` (except SKILL.md which is UPPERCASE).
4. **Cross-references** — every path the new files reference must exist (skip this check for references to other new files being created in the same operation).

Report any check failure as a blocking issue; do not consider the skill "done" until checks pass.

### 7. Tell the user

Summary back to the user:

```text
Created skill: /<name>
  ./skills/<name>/SKILL.md (<lines>)
  ./skills/<name>/pipelines/<mode>.md (<lines>)  [if any]

Reference reads in SKILL.md:
  - <each rule/agent referenced>

Next steps:
  - Edit SKILL.md to flesh out the orchestrator logic.
  - If you added subagents, ensure they exist in ./agents/ (use `/author create agent <name>` if not).
  - Once the skill is functional, you can invoke it with /<name>.
```

---

## Failure modes

- **Name conflicts** — if `<name>` already exists, do not overwrite; ask for a different name or report and stop.
- **Frontmatter typos** — `description` longer than 1,536 chars truncates; warn if it crosses ~1,400 to leave a safety buffer.
- **Pipeline mode names** — must be snake_case `.md` files. Reject kebab-case here.
