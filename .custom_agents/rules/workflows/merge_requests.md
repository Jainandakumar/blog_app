---
last_reviewed: 2026-05-19
---

# Merge requests

Creating and managing GitHub merge requests. Branch mechanics live in
[git.md](git.md); commit-message rules live in [commits.md](commits.md).

---

## Option 1 — Create MR via `git push` (preferred for AI agents)

```bash
git push -u origin MDP-123456_my_feature \
  -o merge_request.create \
  -o merge_request.target=develop \
  -o "merge_request.title=MDP-123456 Brief description of changes" \
  -o merge_request.remove_source_branch
```

### Available push options

- `merge_request.create` — create MR on push
- `merge_request.target=BRANCH` — target branch (default `develop`)
- `merge_request.title=TITLE` — MR title (no newlines allowed)
- `merge_request.description=DESC` — MR description (no newlines allowed)
- `merge_request.remove_source_branch` — delete branch after merge
- `merge_request.draft` — create as draft MR

**Note.** Push options only work when pushing new commits. If the branch is
already up-to-date with the remote, use Option 2.

---

## Option 2 — Create MR via GitHub web UI

1. Push your branch: `git push -u origin MDP-123456_my_feature`.
2. Go to GitHub and create the merge request.
3. Fill out the template:
   - Description of changes
   - Related tickets
   - Testing steps
   - Screenshots (if UI changes)
4. Assign reviewers (usually `CODEOWNERS`).
5. Add labels (`feature`, `bugfix`, etc.).

---

## Targeting protected branches

MRs targeting `master` or the current release branch require explicit human
approval and follow the hotfix flow. See [git.md](git.md) §Deployment flows
and `./skills/develop/workflows/hotpatch.md`.

---

## Related

- [git.md](git.md) — branch strategy, agent ownership
- [commits.md](commits.md) — commit-message format
- `./skills/develop/workflows/hotpatch.md` — release-branch + master MR
  flow
