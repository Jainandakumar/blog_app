# Pipeline — Create a New Rule

Scaffolds a new rule at `./rules/<topic>/<name>.md`.

---

## Inputs

From `/author create rule <topic>/<name>`:
- `<topic>` — the topic folder (`architecture`, `style`, `design`, `security`, `testing`, `workflows`, `planning`, `troubleshooting`, `meta`, `agent_authoring`, `git`, `jira`, etc.).
- `<name>` — lowercase snake_case file stem.

If either is missing, ask the user. Confirm the topic folder name exists or is being created.

---

## Steps

### 1. Validate the path

- Topic folder name: lowercase snake_case.
- File name: lowercase snake_case `.md`.
- Must not already exist at the target path.
- If the topic folder doesn't exist, create it (and create `./rules/<topic>/README.md` as a topic index — see step 5).

### 2. Gather rule details

Ask the user via `AskUserQuestion`:

1. **Does this rule correspond to a real code-path pattern** (a directory, filename pattern, or language)? If yes → Mode C — get the `paths:` globs (see item 3). Prefer Mode C whenever a real binding exists: it's the only mode that costs nothing in sessions that never touch matching files.
2. **If no — does it apply to literally every session, without exception** (not just every code-writing session — that's Mode C with a broad glob)? If yes → Mode B; confirm it qualifies: (a) every session, every agent, no exception, (b) ≤80 lines, (c) the decision log will gain an entry. Any "no" → Mode A.
3. **If Mode C** — confirm the globs by testing them with `Glob` against the repo before finalizing. A glob matching zero real files silently produces a rule nobody ever sees.
4. **If Mode A** — this rule has no code-path binding and doesn't qualify as universal. **It requires a `MdExcludes` entry in `./settings.json`, not just the frontmatter shape** — per `instruction_authoring.md` §5, lacking `paths:` means  Code loads the file unconditionally into every session and every subagent; it is NOT "explicit read only" on its own. Skipping this recreates the bug fixed 2026-08-12/13 (see `decision_log.md`).
5. **Summary** — one sentence on what the rule says.
6. **Why does this rule exist?** — the reason behind it. This goes into the body's "Why" line (Convention #4 in `instruction_authoring.md` — every rule has a Why).
7. **Who reads it?** — list the skills/agents that should reference this rule (Mode A) or that benefit from auto-attach (Mode B/C).

### 3. Write the rule file from the template

Read [./skills/author/templates/rule.md](../templates/rule.md). Fill in:
- Frontmatter per the chosen mode (see [./rules/meta/frontmatter_specs.md](../../../rules/meta/frontmatter_specs.md)).
- Title (H1).
- Body with **Rule**, **Why**, **How to apply** sections — minimum.
- Examples if the rule has non-obvious applications.

### 4. Update the topic README

If the topic folder existed, update its `README.md` to add a row for the new rule.

If the topic folder is new, create the `README.md`:
- One-paragraph topic scope (what's in, what's out).
- A table indexing the subtopic files with one-line summaries.

### 5. Sync loading-mode side effects

- **Mode A** — add an entry to `./settings.json`'s `MdExcludes` for the new file's exact path (or confirm an existing directory-wide glob for that topic folder already covers it — check none of the other files under that glob are `universal: true` first). Validate the JSON after editing. This step is not optional; a Mode A file without it loads unconditionally regardless of what its frontmatter says.
- **Mode B** — add a decision-log entry (required per `instruction_authoring.md` §5):

  ```markdown
  ## YYYY-MM-DD — `<topic>/<name>.md` promoted to universal (Mode B)

  **Decision.** This rule loads universally because <reason>.

  **Rejected alternatives.**
  - Mode A (explicit read) — <why insufficient>
  - Mode C (path-scoped) — <why insufficient>

  **Why.** <full reasoning>

  **Revisit if.** <condition>
  ```

- **Mode C** — no side effect needed; the `paths:` frontmatter is self-contained.

### 6. Run convention checks

1. **Line count** — ≤200 for Mode A/C, ≤80 for Mode B.
2. **Frontmatter** — required fields per the chosen mode.
3. **Naming** — snake_case `.md`.
4. **No duplication** — grep `./rules/` for content the new rule restates. If found, propose extending the existing rule instead.
5. **`MdExcludes` coverage (Mode A only)** — confirm the new file matches an exact-path or directory-glob entry in `./settings.json`, per `audit.md` Check 5. A Mode A file that fails this check is loading unconditionally right now, not "pending a later audit."

### 7. Tell the user

```text
Created rule: ./rules/<topic>/<name>.md (<lines>, Mode <X>)

Topic README updated: ./rules/<topic>/README.md
Decision log updated: ./rules/meta/decision_log.md  [if Mode B]
settings.json MdExcludes updated: <entry added / already covered>  [if Mode A]

Skills/agents that should reference this rule:
  - <list>

Next steps:
  - Add explicit reference reads in the listed skills/agents.
  - If the rule grows past its line cap, split by section.
```

---

## Failure modes

- **Mode B without qualification** — refuse to create as universal; explain the criteria and offer to create as Mode A instead.
- **Topic folder typo** — surface existing topics and ask the user to pick or confirm new.
- **Duplication match** — if the new rule's intent overlaps an existing one, do not create the new file; ask the user to extend the existing rule.
