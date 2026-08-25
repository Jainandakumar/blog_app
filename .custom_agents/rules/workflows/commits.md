---
last_reviewed: 2026-05-19
---

# Commit messages

How to author a commit message. Branch/MR mechanics live in
[git.md](git.md) and [merge_requests.md](merge_requests.md).

---

## Format

```
MDP-NNNNNN Brief summary in present tense

Optional: More detailed explanation focusing on WHY, not just WHAT.
Wrap at 72 characters.

Co-Authored-By: [AI Model Name if AI generated code]
```

## Requirements

- **Always** start with the ticket number: `MDP-NNNNNN`.
- Use present tense ("Add feature", not "Added feature").
- Focus on the purpose / impact of the change, not a play-by-play of the diff.
- Include a `Co-Authored-By:` trailer when AI generated the code.

## Good vs bad

**Good:**

- `MDP-123456 Add user search to improve admin workflow`
- `MDP-123456 Fix enrollment date validation for month boundaries`

**Bad:**

- `Fix bug` (no ticket, no context)
- `MDP-123456 Update code` (too vague)

---

## Commit frequency for AI agents

- Commit after each logical unit (a method, a file, a migration).
- Commit migration files **with** their `schema.rb` changes — together, one
  commit.
- Target ≈300 lines per MR to keep reviews manageable.

---

## Local conventions

`./rules/LOCAL.md` (if present) may define per-developer commit
conventions. Read it alongside this file.

---

## Related

- [git.md](git.md) — branching and agent ownership
- [merge_requests.md](merge_requests.md) — creating MRs from a commit
- [../LOCAL.md](../LOCAL.md) — local commit conventions
