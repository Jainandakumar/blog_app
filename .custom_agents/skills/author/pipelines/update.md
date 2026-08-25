# Pipeline — Update an Existing File

Edits an existing instruction file (skill, agent, or rule) and runs convention checks after the edit.

---

## Inputs

From `/author update <path>`:
- `<path>` — the file to edit, relative to repo root.

If missing or ambiguous, ask the user. Glob/grep helps narrow if the user gives a partial path.

---

## Steps

### 1. Classify the file

Determine the file's type from its path:
- `./skills/<x>/SKILL.md` — Skill orchestrator.
- `./skills/<x>/<anything>.md` — Skill-internal file (pipeline, etc.).
- `./agents/<name>.md` — Subagent.
- `./rules/<topic>/<name>.md` — Rule.
- `./rules/<topic>/README.md` — Topic index.
- `.md` / `AGENTS.md` — Project entry file.

If the path doesn't fit any of these, report and stop. Files outside `./` and the root entry files are out of `/author` scope.

### 2. Read the current file

Read the full file. Note current line count, frontmatter shape, and what it references.

### 3. Gather the change

Ask the user (if not already implied by the invocation):

1. **What's changing?** — content, frontmatter, mode, references, all of the above.
2. **Why?** — captured for potential decision-log entry if it's an override.
3. **Is this an override of an existing convention?** — if yes, prepare a decision-log entry.
4. **If this is a rule file and the loading mode is changing** — moving TO Mode A requires adding a `MdExcludes` entry in `./settings.json` (or confirming an existing directory glob covers it); moving AWAY from Mode A requires removing the now-stale entry if the file had its own exact-path entry (leave directory-wide globs alone if other files under them still need it). A rule left in the old mode's exclude state is either loading unconditionally when it shouldn't, or invisibly excluded when it should be conditional.

### 4. Apply the edit

Use `Edit` (preferred) or `Write` (for full rewrites). Preserve frontmatter unless the change explicitly modifies it.

### 5. Run convention checks against the updated file

1. **Line count** — applicable cap depends on the file type:
   - SKILL.md, pipeline, agent, rule: ≤200.
   - Universal-mode rule (`universal: true`): ≤80.
   - Folder README: ≤150 (these are index files, not content).
2. **Frontmatter** — present and matching the file type per [frontmatter_specs.md](../../../rules/meta/frontmatter_specs.md).
3. **Naming** — file name still matches convention for its type.
4. **Cross-references** — every path the file references must exist.
5. **`MdExcludes` sync (rule files whose mode changed)** — Mode A files must match a `MdExcludes` entry; Mode B/C files must NOT be covered by a stale one, per `audit.md` Check 5.

### 6. If the edit overrides a convention, add a decision-log entry

Append an entry to `./rules/meta/decision_log.md`:

```markdown
## YYYY-MM-DD — <file> overrides <convention>

**Decision.** This file exceeds/diverges from <convention> because <reason>.

**Rejected alternatives.**
- <option>: <why rejected>

**Why.** <reason>

**Revisit if.** <condition>
```

### 7. If `last_reviewed` is present, bump it

For rule files, set `last_reviewed:` to today's date. Per convention, bump only when the rule has been meaningfully reviewed against current reality — typo fixes don't count.

Ask the user: "Is this edit a meaningful content review, or just a content tweak?" Bump only on "meaningful."

### 8. Tell the user

```text
Updated: <path> (<lines>)

Checks:
  Line count: <pass/fail>
  Frontmatter: <pass/fail>
  Naming: <pass/fail>
  Cross-references: <pass/fail>
  MdExcludes sync: <pass/fail/n-a>

Decision log: <updated/no change>
last_reviewed: <bumped to YYYY-MM-DD / unchanged>
```

If any check failed, the file is in an inconsistent state — surface this prominently.

---

## Failure modes

- **Edit causes line-count overflow.** Surface and ask the user: split into sibling files (recommended), or override with decision-log entry.
- **Frontmatter regression.** If the edit removed a required field, restore it and ask the user.
- **Cross-reference now broken.** If the edit references a path that doesn't exist, surface it. The user may be referencing a file that's coming in a subsequent commit — accept with a TODO marker if so.
- **File classification ambiguous.** If `<path>` doesn't fit any pattern but the user insists, stop and surface — file may belong somewhere else entirely.
- **Mode changed but `MdExcludes` wasn't touched.** Fix it before finishing, don't just flag it — an untouched exclude list after a mode change leaves the file either unconditionally loading (missed Mode A entry) or invisible to  when it should be conditional (stale entry left after moving to Mode C).
