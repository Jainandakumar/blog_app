---
last_reviewed: 2026-05-19
---

# Planning rules

Shared rules and reusable templates for feature planning. The procedural
*how to break a Jira Feature into Stories* workflow lives in the
[`/planning` skill](../../skills/planning/SKILL.md); this folder holds the
durable templates and conventions the skill — and any manual planning work —
reads.

---

## Contents

| File | What it covers |
|---|---|
| [user_stories.md](user_stories.md) | User-story format ("As a … I want … so that …") and Given/When/Then acceptance criteria. |
| [tech_design.md](tech_design.md) | When to write a technical design doc, the canonical template, and section-by-section rules. |
| [task_breakdown.md](task_breakdown.md) | Slicing principles (small / vertical / independent / testable), task template, and GitHub issue template. |
| [safe_update_strategy.md](safe_update_strategy.md) | Strategies (Feature Toggle, Parallel Change, Branching by Abstraction, Deprecation) for keeping existing behavior stable through a Feature's changes; required Setup/Cutover/Cleanup stories. |
| [run_state.md](run_state.md) | `[workspace]/CONTEXT.md` and `STATE_<skill>.md` formats every orchestrator skill uses to track progress and resume cheaply. |
| [completion_checklist.md](completion_checklist.md) | The "done" definition — code, tests, docs, security, deployment. |

---

## Related

- [`../../skills/planning/SKILL.md`](../../skills/planning/SKILL.md) — the
  `/planning` skill orchestrator
- [`../../skills/planning/workflows/planning.md`](../../skills/planning/workflows/planning.md)
  — high-level lifecycle phases (Discovery → Design → Implementation → Review
  → Deployment) that frame where this folder's rules apply
- [`../workflows/`](../workflows/) — implementation and shipping conventions
  the completion checklist references
- [`../testing/`](../testing/) — test-authoring rules
- [`../yard/README.md`](../yard/README.md) — code documentation rules
- [`../security/`](../security/) — security checklist
