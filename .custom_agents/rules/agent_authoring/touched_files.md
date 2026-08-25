---
last_reviewed: 2026-05-20
---

# `.-touched-files` housekeeping

Skills that modify source files keep a session-scoped record at
`.-touched-files` (project root) so commit hooks know which files
should carry the AI co-author trailer. This rule defines the format and
the cleanup protocol skills run before and after work.

## File format

- One relative file path per line, matching `git diff --name-only` output
  (e.g. `app/models/user.rb`).
- Empty lines and `#` comment lines are ignored.
- Paths must be exact — no globs, no leading `./`, no trailing whitespace.
- Git hooks (`.githooks/prepare-commit-msg`, `.githooks/post-checkout`)
  use `grep -qxF` for exact full-line matching, so any deviation breaks
  matching.

A `settings.json` Edit/Write hook appends paths automatically on every
tool use that writes to disk — including gitignored paths under
`.workspace/`. Those automatic additions are stripped during cleanup.

## Cleanup at skill startup

Skills that orchestrate file changes (`/develop`, `/develop fix`, future
similar skills) run this cleanup at startup:

1. If `.-touched-files` exists, review each entry.
2. Remove entries where the file no longer exists, **or** where the file
   has no uncommitted changes against any of:
   - `git diff --name-only` (unstaged changes)
   - `git diff --cached --name-only` (staged changes)
   - `git ls-files --others --exclude-standard` (untracked)
3. Keep an entry only if the file appears in **any** of the three
   commands above.

Stale entries are expected — gitignore can change, the auto-append hook
captures workspace writes that don't end up in commits, etc. Tracking
everything and cleaning at startup is the safest baseline.

## Cleanup after a successful commit

After a commit succeeds:

1. Remove entries for files that were just committed (they now carry the
   AI co-author trailer in the commit message, so tracking is complete).
2. If the file becomes empty, delete it.

## Related

- [`../git/commit_trailer.md`](../git/commit_trailer.md) — the AI
  co-author trailer commit hooks add for tracked files.
- [`workspace_output.md`](workspace_output.md) — workspace writes vs
  source-tree writes.
