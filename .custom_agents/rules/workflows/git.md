---
last_reviewed: 2026-05-19
---

# Git workflow

Branch strategy, agent ownership of git commands, deployment flows, and
feature-branch management. Commit-message authoring is in
[commits.md](commits.md); MR authoring is in [merge_requests.md](merge_requests.md).

---

## Agent ownership

Git commands are categorized by type. Only the **Orchestrator** executes
state-changing commands.

| Command Type | Commands | Who Can Execute |
|---|---|---|
| **Read-only** | `git status`, `git diff`, `git log`, `git branch --show-current` | Any agent |
| **State-changing** | `git checkout`, `git add`, `git commit`, `git push`, `git rebase`, `git merge`, `git cherry-pick` | Orchestrator only |

**Why.** State-changing commands affect the shared environment and require
user coordination. Other agents (like the reviewer) may read git state but
must delegate modifications to the Orchestrator.

---

## Branch strategy

| Branch | Purpose | Protected |
|---|---|---|
| `master` | Production code (100% stable) | Yes |
| `develop` | Integration branch (default — all MRs target this) | Yes |
| *release branch* | Hot-fix staging / release testing (changes each cycle) | Yes |
| `MDP-NNNNNN_description` | Feature branches | No |

**Protected branches cannot accept direct commits.** Use a feature branch and
a merge request.

---

## Deployment flows

### Standard flow (all `/develop` automated work)

All MRs created by `/develop` target `develop`. This is the only automated
flow.

### Hotfix flow (manual — requires approval at each stage)

```
1. develop          ← MDP-NNNNNN_hotfix    (MR — test the fix here first)
2. <release branch> ← cherry-pick/MR      (requires team approval for release testing)
3. master           ← cherry-pick/MR      (requires team approval for production)
```

Code always goes: develop first → release branch second → master last. Each
stage requires explicit human approval. The AI can help create the MR or
cherry-pick if the user asks, but never initiates this automatically.

### Scheduled release flow (manual — requires approval)

```
1. develop          ← MDP-NNNNNN_feature  (standard MR, can be automated)
2. <release branch> ← merge from develop (requires approval)
```

**Note.** The release branch name changes each release cycle. When a workflow
involves the release branch, ask the developer for the current release
branch name at the start of the workflow so subsequent steps can run
uninterrupted.

### AI behaviour rules

- All auto-generated MRs target `develop` — never the release branch or
  `master` unless the user explicitly asks.
- If a user asks to deploy to the release branch or `master`, help them but
  confirm first.
- Never auto-push to protected branches without explicit user confirmation.

---

## Creating a feature branch

```bash
# CRITICAL: confirm you're not on a protected branch
git branch --show-current

# Start from develop
git checkout develop
git pull origin develop

# Create feature branch — MUST have MDP-NNNNNN_ prefix
git checkout -b MDP-123456_add_user_search

# Work on feature...

# Push to remote
git push -u origin MDP-123456_add_user_search
```

---

## Updating your branch

### Rebase on develop

```bash
git checkout develop
git pull origin develop
git checkout MDP-123456_my_feature
git rebase develop

# If conflicts, resolve and continue
git add .
git rebase --continue

# Force push (rebase rewrites history)
git push origin MDP-123456_my_feature --force-with-lease
```

### Merge develop into your branch

```bash
git checkout MDP-123456_my_feature
git merge develop

# Resolve conflicts if any
git add .
git commit

git push origin MDP-123456_my_feature
```

---

## Stacked MR workflow

When continuing work that depends on changes not yet merged:

```bash
# After creating first MR, continue with dependent work
git push -u origin MDP-123456_your_feature_part1
# Create MR for part1

# Branch FROM current branch (not develop) for continued work
git checkout -b MDP-123456_your_feature_part2
# Continue development with all part1 changes available

# After part1 merges, rebase part2 onto develop
git checkout develop && git pull
git checkout MDP-123456_your_feature_part2
git rebase develop
git push --force-with-lease origin MDP-123456_your_feature_part2
```

---

## CODEOWNERS

- **File location:** `.github/CODEOWNERS`
- **Purpose:** document who owns code areas; require owner review before
  merging; provide point of contact for questions.
- **Team lookup:** https://git.plansource.com/app//-/project_members

**For new code:** add your team as code owners.

```
app/models/new_feature/ @your_team
```

**For major updates:** ask the user — "Would you like to be added as a code
owner alongside [existing_owner]?"

**For minor changes:** leave CODEOWNERS as-is; existing owners will review.

---

## Related

- [commits.md](commits.md) — commit-message format and frequency
- [merge_requests.md](merge_requests.md) — creating and pushing MRs
- [../../rules/LOCAL.md](../LOCAL.md) — local commit conventions
