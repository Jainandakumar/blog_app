---
last_reviewed: 2026-05-19
---

# Branch naming

Feature branches in this repo follow a single convention so the branch name
itself encodes the ticket it implements. Skills that create branches reference
this rule rather than restating the format.

The broader branch *strategy* (protected branches, deployment flows, stacked
MRs) lives in [`../workflows/git.md`](../workflows/git.md). This file covers
only the *name format*.

---

## Format

```
MDP-NNNNNN_short_description_from_summary
```

| Part | Rule |
|---|---|
| Ticket key | Start with the Jira key (e.g., `MDP-233100`). Required. |
| Separator | One underscore between ticket key and description. |
| Description | Short snake_case derived from the ticket summary. |
| Length | Under 60 characters total. |
| Character set | `a-z`, `0-9`, `_`, `-` only. Strip everything else. |
| Casing | All lowercase except the `MDP-` prefix. |

### Examples

| Ticket summary | Branch name |
|---|---|
| Add field validation to subscriber form | `MDP-233100_add_field_validation` |
| Fix premium calculation rounding | `MDP-234567_fix_premium_rounding` |
| Spike: investigate Tagatha rollout strategy | `MDP-235001_spike_tagatha_rollout` |
| Hotfix: NPE in deduction recalc | `MDP-235122_hotfix_deduction_recalc` |

---

## Creating the branch

```bash
git checkout -b MDP-NNNNNN_short_description
```

Branch from the appropriate base (typically `develop`; see
[`../workflows/git.md`](../workflows/git.md) for hotfix and stacked flows).

---

## Spike tickets

Spikes are research-only and produce no MR. **Do not create a branch for a
Spike ticket** — the workspace lives under `.workspace/<ticket>/` instead.

---

## Branch lifecycle

Keep the feature branch until the MR is merged. Never delete a branch before
merge.

- **Auto mode (skills running unattended).** After observing a merge (via
  polling), delete the local branch automatically:
  `git checkout develop && git branch -D <branch>`.
- **Interactive / guided modes.** If polling observes a merge, delete
  automatically. If the user reports a merge, ask before deleting.

---

## Related

- [`README.md`](README.md) — git-rules folder index.
- [`../workflows/git.md`](../workflows/git.md) — branch strategy, protected
  branches, deployment flows.
- [`commit_trailer.md`](commit_trailer.md) — AI co-author trailer for commit
  messages and Jira free-text bodies.
