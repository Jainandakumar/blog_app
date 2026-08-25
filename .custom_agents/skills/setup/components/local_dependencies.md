# Component: Local dependencies

Local CLI tools and per-repo wiring that skills and agents assume are
available on the host. Each tool below has a Check, a macOS install command,
and a one-line rationale.

When Linux support is added later, add an `apt-get install ...` (or
equivalent) section under each tool. This file is the canonical place for
those equivalents — do not scatter install commands across other skills or
agents.

---

## ffmpeg

**Rationale.** The `bug_video_analysis` agent uses ffmpeg to extract frames
from video attachments on Bug tickets.

### Check

```bash
which ffmpeg
```

- Exit 0 and a path printed → **PASS**. Report `ffmpeg: OK (<version>)`.
- Exit non-zero or no path → **FAIL**. Run install.

### Verify

```bash
ffmpeg -version
```

Confirm the first line parses as `ffmpeg version <X.Y.Z>`.

### macOS install

```bash
brew install ffmpeg
```

---

## jq

**Rationale.** JSON parsing in pipeline scripts under `supporting_scripts/`
and in several skill dispatchers.

### Check

```bash
which jq
```

- Exit 0 → **PASS**. Report `jq: OK (<version>)`.
- Exit non-zero → **FAIL**. Run install.

### Verify

```bash
jq --version
```

### macOS install

```bash
brew install jq
```

---

## Git repository & branch

### Check

```bash
git rev-parse --is-inside-work-tree
```

- `true` → **PASS**. Also report `current branch: <name>` for context (any
  branch is acceptable; this is informational).
- Anything else → **FAIL** with message `not a git repository`.

```bash
git branch --show-current
```

No install step — if this isn't a git repo, the user is in the wrong
directory.

---

## Git hooks path

**Rationale.** Enables the AI co-authorship tracking hooks in `.githooks/`.

### Check

```bash
git config core.hooksPath
```

Expected value: `.githooks`.

- Matches → **PASS**.
- Empty or different value → run Setup.

### Setup

```bash
git config core.hooksPath .githooks
```

---

## Bundle status

**Rationale.** Gems must be installed before specs or Pronto can run.

### Check

```bash
bundle check
```

- `The Gemfile's dependencies are satisfied` → **PASS**.
- Otherwise → **FAIL**. Tell the user: "Run `bundle install` to install
  dependencies."

This component does not run `bundle install` automatically — the user owns
that step (it can take minutes and they may want to review the diff first).

---

## Pronto binstub

**Rationale.** `bin/pronto` is the canonical invocation for code review.

### Check

```bash
test -x bin/pronto
```

- Exit 0 → **PASS**.
- Exit non-zero → **FAIL**. Tell the user: "Run `bundle binstubs pronto` to
  create the binstub."
