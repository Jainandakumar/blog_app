---
last_reviewed: 2026-08-03
---

# Code review rules

Shared rules for reviewing code on this project — the reviewer's role, what to
flag, what to ignore, severity definitions, and the "What's Done Well" mandate.

## Subtopic index

| File | Topic |
|---|---|
| [`review_criteria.md`](review_criteria.md) | Reviewer role, approach, what to flag and ignore, severity definitions, quality mandate. |
| [`advisory_findings.md`](advisory_findings.md) | Feature-level review only — the separate "judgment call" category (intent gaps, usability, consistency, spec critique) kept apart from concrete findings. |
| [`feature_review_interactive_ux.md`](feature_review_interactive_ux.md) | Feature-level review only — the pre-flight interactive gate's voice and reclassification rules (Known Issue ↔ Advisory), before anything posts. |

## When to read this folder

- Performing a local code review (see `./skills/code-review/`).
- Performing the MR-level review step inside `/develop` Step 10.
- Performing a Feature-level review (see `./skills/code-review/feature_review_instructions.md`).
- Authoring or updating an agent that asks the model to assess code quality.

## Related

- [`../yard/README.md`](../yard/README.md) — YARD documentation rules; reviewers verify these on public methods.
- [`../style/README.md`](../style/README.md) — Style rules; reviewers load by changed-file path.
- [`../design/README.md`](../design/README.md) — Design rules; reviewers load by changed-file path.
- [`../security/README.md`](../security/README.md) — Security rules; reviewers always load.
