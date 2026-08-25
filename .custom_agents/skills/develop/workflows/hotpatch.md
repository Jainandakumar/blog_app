---
last_reviewed: 2026-05-19
---

# Hot-patch workflow

For bug fixes that need to reach production before the next release. Used
after the develop-targeted MR for a Bug has merged.

---

## Overview

Hot patches travel through this path:

```
develop → <release branch> → master
```

Each step requires a separate MR and explicit human approval. See
[../../../rules/workflows/git.md](../../../rules/workflows/git.md) §Hotfix
flow for the policy frame.

---

## Step 1 — Develop and test in `develop`

First, create and test the fix using the normal workflow:

```bash
git checkout develop
git pull origin develop
git checkout -b MDP-123456_fix_description
# Make fix...
git push -u origin MDP-123456_fix_description
# Create MR targeting develop; get it merged
```

---

## Step 2 — Cherry-pick to the release branch

After the fix is merged to `develop`:

```bash
git checkout <release-branch>
git pull origin <release-branch>
git checkout -b MDP-123456_fix_description_rc
git cherry-pick <commit-hash-from-develop>
# Adapt as needed for divergence between develop and the release branch
git push -u origin MDP-123456_fix_description_rc
# Create MR targeting the release branch
```

**Branch-name suffix:** `_rc`.

**Reminder.** Ask the user for the current release branch name at the start
of the workflow — it changes each release cycle.

---

## Step 3 — Cherry-pick to `master`

After the release-branch MR is merged:

```bash
git checkout master
git pull origin master
git checkout -b MDP-123456_fix_description_patch
git cherry-pick <commit-hash-from-release-branch>  # cherry-pick EXACTLY from the release branch
git push -u origin MDP-123456_fix_description_patch
# Create MR targeting master
```

**Branch-name suffix:** `_patch`.

---

## Branch-naming summary

| Target branch | Branch-name pattern |
|---|---|
| `develop` | `MDP-NNNNNN_description` |
| `<release branch>` | `MDP-NNNNNN_description_rc` |
| `master` | `MDP-NNNNNN_description_patch` |

---

## Important notes

- Always cherry-pick from the previous branch in the chain
  (develop → release branch → master).
- The code may need adaptation if branches have diverged.
- Each MR requires separate review and approval.
- Don't skip the release branch unless explicitly instructed.
- Never auto-push to protected branches without explicit user confirmation.

---

## Related

- [bugfix.md](bugfix.md) — when to offer this flow (Step 6)
- [../../../rules/workflows/git.md](../../../rules/workflows/git.md) — branch
  strategy and agent-ownership rules for git commands
- [../../../rules/workflows/merge_requests.md](../../../rules/workflows/merge_requests.md) —
  push-option syntax for creating each MR
