---
last_reviewed: 2026-05-19
---

# External tool dependencies

External tools (ffmpeg, ImageMagick, jq, system libraries, etc.) are handled in exactly one place: the `/setup` skill. Skills and agents that use these tools assume they are available — they do not check, install, or troubleshoot.

---

## Rule

`/setup` is the canonical home for **all** external tool installation, configuration, and troubleshooting. Every skill ensures `/setup` has been verified for the current session before doing real work. Once that contract is in place, skills and agents that use a tool can simply use it — no presence checks, no install instructions, no per-platform branching.

---

## Why

Scattered install instructions cause three problems:

1. **Inconsistency.** Different agents tell developers to install the same tool in different ways. One says `brew install ffmpeg`, another says "see the README," a third skips it entirely.
2. **Logic bloat.** Skill and agent files swell with `if tool exists / else / fall back` branches that are the same everywhere.
3. **Lost visibility.** "What does this project need installed?" should have one answer (the `/setup` skill). When tool requirements are distributed across many files, the team can't audit or maintain the dependency surface.
4. **Cross-platform drift.** When install logic lives in many files, supporting a new OS (Linux, Windows-via-WSL) means editing every one. With the logic in `/setup`, only `/setup` changes — the rest of the instruction layer stays portable.

The convention frees skills to focus on their actual work and concentrates dependency management where it belongs.

---

## How to apply

### Writing a new skill

Every skill's `SKILL.md` includes (or implies) a startup step:

> Before doing real work, ensure `/setup verify` has succeeded for this session. If it hasn't, run it.

The `/author` skill's `create_skill` pipeline includes this in the skill template. Existing skills should add it (Phase 6 cleanup).

### Writing a new agent

Agents do **not** check for or install tools. They use them as if they were already installed (because, per the skill contract above, they are). An agent uses `ffmpeg`, `jq`, or any other CLI exactly the way it would be used in a developer's terminal — no preamble, no fallback.

### Adding a new external tool to the project

Add a check + install path to the `/setup` skill. Each tool needs:

- A check command.
- An install command per supported platform (macOS minimum — `setup-mac.md`; Linux when adopted — `setup-linux.md`).
- A verify step.
- A one-line rationale for why the tool is required.

### Cross-platform

`/setup` is the **only** place that varies by OS. Skills, agents, and rules stay portable. Future platform support (Linux, WSL) means new files inside `/setup`, not edits elsewhere.

---

## What this rule does NOT cover

- **Configuration files** (`./atlassian.json`, `./github.json`) — those are configuration, handled by the skills that need them.
- **Per-session credentials** (API tokens, OAuth) — handled by `/setup` as part of credential management.
- **Project dependencies** (gem versions, npm packages) — those live in the standard package files (`Gemfile`, `package.json`) and don't fit this rule.

---

## Related rules

- `./rules/meta/instruction_authoring.md` — overall conventions (see §11 on the skill ↔ `/setup` contract).
