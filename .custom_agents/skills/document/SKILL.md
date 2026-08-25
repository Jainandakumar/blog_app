---
name: document
description: Apply feature documentation and YARD to the changed files in the current branch.
disable-model-invocation: true
---

# Documentation — Launcher

Applies **feature documentation** (`docs/features/`) and **YARD** to the files
changed in this branch, in one pass. Takes no arguments. See
`./rules/documentation/feature_docs.md` and `./rules/yard/README.md`.

**Mode.** Detect per `../../rules/develop/pipeline_modes.md`
(`_CODE_ENTRYPOINT=sdk-cli` → `headless`; otherwise `interactive`).
This skill makes file edits; in headless mode `AskUserQuestion` gates
are skipped and YARD application proceeds for every changed file.

## Setup Check

Before doing real work, ensure `/setup verify` has succeeded for this
session. If it hasn't, run `/setup` first.

## What To Do

### Step 1: TodoWrite checklist

```
1. Determine branch-diff scope (pending)
2. Apply feature docs + YARD to changed files (pending)
3. Report results (pending)
```

### Step 2: Determine branch-diff scope

Run the operational git work yourself — do NOT delegate to a subagent.

1. Get the current branch:
   ```bash
   git branch --show-current
   ```

2. Decide which diff range applies:
   - If the current branch is `develop`, `master`, or matches `release-*`:
     scope to staged + unstaged changes only.
   - Otherwise (feature branch): scope to committed changes vs `develop` plus
     staged + unstaged.

3. Collect changed files via these `git diff` invocations, deduplicated:

   **Feature branch:**
   ```bash
   git diff --name-only develop...HEAD          # committed vs develop
   git diff --name-only                          # unstaged
   git diff --name-only --cached                 # staged
   ```

   **Protected branch (develop / master / release-*):**
   ```bash
   git diff --name-only                          # unstaged
   git diff --name-only --cached                 # staged
   ```

4. Filter the deduplicated list:
   - Keep only `.rb` files.
   - Exclude paths matching `spec/**`, `test/**`, `db/migrate/**`.
   - Drop any files that no longer exist (deleted).

5. If the filtered list is empty: report "No Ruby files to document in this
   branch." Mark all TodoWrite items completed and stop.

### Step 3: Apply feature docs, then YARD

Feature docs and YARD are authored **together** so the `@see` ↔ `paths:` link
is consistent — see `./rules/documentation/feature_docs.md`. Run
`document_feature` first (it sets each doc's `paths:`), then `document_yard`
(it wires each entry-point class's `@see`).

`[WORKSPACE PATH]` is `.workspace/document_session/` (create if missing —
gitignored under the `.workspace/*` rule).

**1. Feature docs** — launch `document_feature`:

```
"Read `./agents/document_feature.md` for your instructions.

changed_files: [LIST OF CHANGED .rb FILES]
functional_area: [empty — /document has no ticket; resolve docs by paths: match]
workspace: [WORKSPACE PATH]
Local overrides: [relevant items from LOCAL.md, if any]

Verify/enhance the feature docs covering these files per
`./rules/documentation/feature_docs.md`. No ticket anchor — resolve by
`paths:` match, flag gaps, do not bootstrap."
```

**2. YARD** — launch `document_yard` on the same files:

```
"Read `./agents/document_yard.md` for your instructions.

Files to document: [LIST OF .rb FILES]
Workspace: [WORKSPACE PATH]
Local overrides: [relevant items from LOCAL.md, if any]

Apply YARD per `./rules/yard/README.md` to public methods, classes,
and modules. Skip private methods. Verify existing YARD; do not rewrite
correct YARD. Apply the bidirectional `@see` ↔ `paths:` check per
`./rules/yard/cross_references.md`, wiring `@see` to the feature docs
just verified. Flag (do not create) any remaining feature-doc gaps."
```

The agents write detail to `[workspace]/feature_changes.md` and
`[workspace]/yard_changes.md`.

### Step 4: Report results

After the agents return, post a summary to the user with:

- Files modified (count and list)
- **Feature docs:** verified / enhanced / created (counts); detail docs split (count)
- **`doc_review.md`:** deferred items logged (count)
- Public methods updated (count); classes with new YARD docstrings (count)
- `@see` tags added or verified (count)
- Feature-doc gaps flagged (count, list)
- Any `NEEDS_DECISION` items surfaced

If files were modified, suggest the user review the diff before committing.
Do NOT commit on the user's behalf — `/document` ends at "changes applied
locally; review and commit when ready."

## Critical rules

- **No arguments.** Every run does both feature docs and YARD, in one pass
  (feature docs first, then YARD wires `@see`).
- **Idempotency.** If a method already has correct, complete YARD, leave
  it alone. The agent should NOT rewrite YARD just because it touched the
  file.
- **Scope is the branch diff only.** Do not document files that haven't
  changed. The whole point is to focus YARD work on what was edited.
- **Do not modify tests.** Even if a `.rb` test file appears in the diff
  (it won't — we exclude `spec/`/`test/` — but as a backstop), do not
  add YARD to it.
- **Do not commit.** This skill ends at "changes applied locally."

## Compaction safety

If the agent returns mid-run after partial progress, follow the recovery
pattern in `./rules/agent_authoring/compaction_recovery.md` —
check the workspace file for what was completed and relaunch with the
remaining files.
