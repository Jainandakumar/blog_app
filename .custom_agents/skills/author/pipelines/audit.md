# Pipeline — Audit Existing Files

Scans instruction files for convention violations. Runs five checks by default:

1. Line-count cap
2. Frontmatter compliance
3. Naming + broken cross-references
4. .md / AGENTS.md sync check
5. Unconditional-load hygiene (`MdExcludes` coverage)

---

## Inputs

From `/author audit [path]`:
- No arg: full audit across `./skills/`, `./agents/`, `./rules/`, `.md`, `AGENTS.md`.
- Path: single-file audit.

---

## Scope by mode

| Mode | Files audited |
|---|---|
| Full audit | All `*.md` under `./skills/`, `./agents/`, `./rules/`, plus root `.md` and `AGENTS.md`. |
| Single-file | The given path only (skip the sync check unless the path is .md or AGENTS.md). |

---

## Check 1 — Line-count cap

For each file, compute line count (`wc -l`) and compare against its cap:

| File type | Cap |
|---|---|
| Skill `SKILL.md`, skill pipeline, agent, Mode A or Mode C rule | 200 |
| Universal Mode B rule (frontmatter has `universal: true`) | 80 |
| Folder `README.md` (index files) | 150 |
| `.md` | 200 |
| `AGENTS.md` | 200 |

**Output per violation:**

```text
LINE-COUNT  <path>  <actual>/<cap>  +<over> over
```

**Decision-log exception.** If the file's decision-log entry overrides the line cap, mark as "override (logged)" not as a violation.

**Append-only log exemption.** `decision_log.md` and similar append-only log files are exempt from the line cap (per `instruction_authoring.md` §4). Skip the line-count check for these.

---

## Check 2 — Frontmatter compliance

For each file, parse YAML frontmatter (between leading `---` lines) and validate against the schema for the file type. Schemas live in [./rules/meta/frontmatter_specs.md](../../../rules/meta/frontmatter_specs.md).

Required fields per type:

| Type | Required | Optional |
|---|---|---|
| Skill `SKILL.md` | `name`, `description` | `disable-model-invocation`, `allowed-tools` |
| Agent file | `name`, `description` (if invoked via `subagent_type`) | — |
| Rule, Mode A | `last_reviewed` (+ a `MdExcludes` entry — see Check 5) | — |
| Rule, Mode B (universal) | `universal: true`, `last_reviewed` | — |
| Rule, Mode C (path-scoped) | `paths`, `last_reviewed` | — |
| Feature doc (top-level) | `feature`, `summary`, `paths`, `tags`, `last_reviewed` | `related_features` |
| Feature doc (subtopic) | `parent_feature`, `summary`, `paths`, `last_reviewed` | — |

**Output per violation:**

```text
FRONTMATTER  <path>  missing: <field>     [or]  invalid: <field> (<reason>)
```

---

## Check 3 — Naming + broken cross-references

### Naming

| Path | Required style |
|---|---|
| Skill folder | lowercase-hyphen |
| Skill files (not SKILL.md) | snake_case `.md` |
| Agent file | snake_case `.md` |
| Rule topic folder | snake_case |
| Rule file (not README) | snake_case `.md` |
| Folder index | `README.md` exactly |

**Output per violation:**

```text
NAMING  <path>  expected <style>, found <found>
```

### Broken cross-references

For each file, find Markdown links and bare paths to `./...` or `docs/...`. For each, verify the target exists.

`grep -oE '[\.\/_a-zA-Z0-9-]+\.(md|rb|yml|json)' <file>` plus `\./[^ )"\\]+` and `docs/[^ )"\\]+` patterns. Filter to actual paths (skip code blocks if practical — false positives are acceptable but should be flagged for human review).

**Output per violation:**

```text
BROKEN-REF  <source-file>:<line>  →  <referenced-path>  (target missing)
```

---

## Check 4 — .md / AGENTS.md sync

Both files have universal-rules sections that should agree.

1. Read `.md` and `AGENTS.md`.
2. Find sections marked as "Universal Rules" or equivalent. (Both files should use the same section heading per convention.)
3. Compare the rule statements line-by-line. Differences are reported.

**Output per violation:**

```text
SYNC  .md vs AGENTS.md  diff in section "<heading>":
  + only in .md: <line>
  - only in AGENTS.md: <line>
```

A small intentional difference is fine (e.g. .md may have -Code-specific additions). But the shared universal-rules content must match.

---

## Check 5 — Unconditional-load hygiene (`MdExcludes` coverage)

Any `.md` file under `./rules/` without a `paths:` field loads
unconditionally into every session **and every non-fork subagent**
(lacking `paths:` is not the same as "explicit read only" — see
[code..com/docs/en/memory](https://code..com/docs/en/memory)).
The only ways to avoid that cost are a genuine `paths:` scope (Mode C)
or an entry in `./settings.json`'s `MdExcludes` array. This
check verifies the two stay in sync so a newly-added rule file doesn't
silently reintroduce unconditional loading.

1. Read `./settings.json`'s `MdExcludes` array (empty list
   if the key is absent).
2. For each `.md` file under `./rules/`, classify it:
   - Has `paths:` frontmatter → Mode C. No action.
   - Has `universal: true` → Mode B. Should NOT match any
     `MdExcludes` pattern — flag `CONTRADICTORY-EXCLUDE` if it does.
   - Neither → Mode A. Must be covered by a `MdExcludes` pattern
     (an exact-file match, or a directory glob such as
     `**/./rules/<dir>/**` containing it) — flag
     `UNCONDITIONAL-LOAD` if not covered.
3. For each pattern in `MdExcludes`, verify it matches at least
   one real file under `./rules/` — flag `STALE-EXCLUDE` if it
   matches nothing (renamed/deleted file, typo'd pattern).

**Output per violation:**

```text
UNCONDITIONAL-LOAD  <path>  (<size>) — no paths:, not in MdExcludes   [WARNING]
CONTRADICTORY-EXCLUDE  <path>  — universal: true but excluded              [BLOCKING]
STALE-EXCLUDE  <pattern>  — matches no file under ./rules/           [WARNING]
```

`UNCONDITIONAL-LOAD` severity scales with size: files over ~8KB
(roughly 2k tokens) are worth flagging as `WARNING`; smaller files are
informational only — not worth a settings churn for a few hundred
tokens. Use `wc -c` as a quick proxy.

---

## Reporting

Aggregate all violations into a single report. Group by check; within each check, group by severity (blocking vs warning).

**Example report:**

```text
/author audit — 2026-05-19

LINE-COUNT (2 violations)
  ./skills/develop/pipelines/develop.md  738/200  +538 over   [BLOCKING]
  ./skills/planning/planning_instructions.md  534/200  +334 over   [BLOCKING]

FRONTMATTER (1 violation)
  ./rules/yard/authoring.md  missing: last_reviewed   [BLOCKING]

NAMING (1 violation)
  ./skills/some-skill/some-file.md  expected snake_case, found kebab-case   [BLOCKING]

BROKEN-REF (0 violations)

SYNC  .md ↔ AGENTS.md
  No drift detected.

UNCONDITIONAL-LOAD (1 violation)
  ./rules/style/new_feature.md  (9.1KB) — no paths:, not in MdExcludes   [WARNING]

Summary: 4 blocking, 1 warning. Run `/author update <path>` to fix.
```

If there are zero violations, report:

```text
/author audit — 2026-05-19
All checks passed (N files audited).
```

---

## Failure modes

- **YAML parse errors** — count as frontmatter violations; report the parse error verbatim.
- **Files outside the convention map** — files in `./` that don't fit any known type are reported as `UNCLASSIFIED <path>`. The user may need to relocate them.
- **Cross-reference false positives** — paths inside code blocks may be flagged as broken. Mark these as `WARNING` not `BLOCKING` and let the human review.
- **Slow on full audit** — if the audit takes more than ~60 seconds, surface progress to the user (counts per check) instead of running silently.
- **Verifying a Check-5 fix.** If the user wants to confirm a `MdExcludes`/`paths:` change actually took effect via `/context`, it must be a *fresh* session — .md/rules loading happens once at session start and doesn't hot-reload mid-session. Checking in an already-running session (including this audit's own) will show stale numbers and isn't evidence the fix failed.
