---
last_reviewed: 2026-05-20
---

# Safe update strategies

How to keep existing behavior stable while a Feature modifies code used in
multiple places. Pick a strategy whenever the Feature changes existing code;
purely additive Features (new endpoints, new models with no callers) don't
need one.

All code must remain **production-ready at every commit**. The strategy
ensures stability throughout development — not just at the end.

---

## Strategy options

| Strategy | When to use | How it works |
|----------|------------|--------------|
| **Feature Toggle** | UI changes, new behavior that replaces old, gradual rollout needed | Wrap new code paths behind `PlanSource::FeatureToggle[:name]`. Old path remains active until cutover. See [`../architecture/feature_toggle.md`](../architecture/feature_toggle.md) for the gem API. |
| **Parallel Change** | Changing method signatures, renaming columns/tables, modifying APIs | Add the new version alongside the old, migrate callers incrementally, then remove the old version. |
| **Branching by Abstraction** | Replacing a subsystem or large internal dependency | Introduce an abstraction layer, implement the new version behind it, switch over, remove the old. |
| **Deprecation Pattern** | Retiring old behavior that external consumers depend on | Mark old code as deprecated with warnings/logging, add the replacement, set a removal timeline. |

---

## Selection rules

1. **User-facing behavior changes:** prefer Feature Toggle — supports QA
   verification, gradual rollout, and instant rollback.
2. **Internal API or data-structure changes:** prefer Parallel Change.
3. **Subsystem replacement:** prefer Branching by Abstraction.
4. **Retiring external-facing behavior:** prefer Deprecation Pattern.
5. **Unsure:** Feature Toggle is the safest default.
6. **Multiple strategies are OK** if different parts of the Feature need
   different approaches — document this clearly.

---

## Feature Toggle naming

When the selected strategy is Feature Toggle:

- Pick a descriptive snake_case name (e.g., `:ben_admin_refresh`,
  `:new_enrollment_flow`).
- **Document the toggle name in the breakdown** — all stories reference the
  same name.
- **The first story creates the toggle** (if it doesn't already exist). All
  subsequent stories use it. Never create duplicate toggles.

---

## Required stories for safe update strategies

Every Feature using a safe update strategy includes these stories in addition
to the implementation stories:

1. **Setup story** (first in order). Creates the toggle / abstraction layer /
   parallel interface. All other stories depend on this.
2. **Cutover story** (after all implementation stories). Enables the toggle
   for all users / migrates all callers to the new path / switches the
   abstraction. Include verification steps.
3. **Cleanup story** (after cutover is verified). Removes toggle checks /
   old code path / abstraction layer / deprecation warnings. This restores
   code simplicity.

The Cutover and Cleanup stories need clear acceptance criteria documenting
what "done" looks like (e.g., "Toggle removed from codebase, no references
to old method remain").

---

## Strategy artifact

`/planning` writes the chosen strategy to
`[workspace]/safe_update_strategy.md` so downstream agents
(`planning_breakdown`, `planning_brief`, `/develop` Step 4) read a single
canonical record:

```
Strategy: [Feature Toggle | Parallel Change | Branching by Abstraction | Deprecation Pattern]
Toggle name: [if Feature Toggle, e.g., :new_enrollment_flow]
Rationale: [1-2 sentences on why this strategy was selected]
Setup story: [brief description]
Cutover story: [brief description]
Cleanup story: [brief description]
```

---

## Related

- [`../architecture/feature_toggle.md`](../architecture/feature_toggle.md) —
  `PlanSource::FeatureToggle` integration patterns
- [`../architecture/feature_toggle_cleanup.md`](../architecture/feature_toggle_cleanup.md)
  — enabling toggles in dev/test, toggle removal procedure
- [`task_breakdown.md`](task_breakdown.md) — sizing and slicing
- [`completion_checklist.md`](completion_checklist.md) — feature-toggle item
  in the deployment section
