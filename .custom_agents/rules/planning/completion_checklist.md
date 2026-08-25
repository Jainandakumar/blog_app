---
last_reviewed: 2026-05-19
---

# Feature completion checklist

The "done" definition for a Feature or Story. Run through this list before
marking a ticket complete, before closing a merge request, and during the
final review pass.

For implementation-level commit/MR mechanics see
[`../workflows/git.md`](../workflows/git.md) and
[`../workflows/merge_requests.md`](../workflows/merge_requests.md). For test
authoring rules see [`../testing/`](../testing/). For YARD docs see
[`../yard/README.md`](../yard/README.md).

---

## Code

- [ ] All acceptance criteria met (per
  [user_stories.md](user_stories.md))
- [ ] Code reviewed and approved
- [ ] Follows style guidelines — Pronto / RuboCop passes
- [ ] No new security vulnerabilities introduced
- [ ] Performance is acceptable for the expected load
- [ ] Code lives in the right place (per
  [`../architecture/code_placement.md`](../architecture/code_placement.md))

---

## Tests

- [ ] Unit tests written and passing
- [ ] Integration / request tests written and passing where applicable
- [ ] Edge cases covered (invalid input, empty data, boundary values,
  permission denial)
- [ ] Coverage meets the project bar — see [`../testing/`](../testing/)

---

## Documentation

- [ ] YARD comments on new public methods (per [`../yard/README.md`](../yard/README.md))
- [ ] Feature docs updated in `docs/features/` if user-visible behaviour
  changed
- [ ] API docs updated in `engines/api/docs/` if the API surface changed
- [ ] CHANGELOG updated if applicable
- [ ] Design doc updated with "as-built" notes (per
  [tech_design.md](tech_design.md))

---

## Security

- [ ] Security checklist completed (per [`../security/`](../security/))
- [ ] No secrets committed (`.env`, API tokens, credentials)
- [ ] Input validation implemented at the boundary that receives it
- [ ] Authorization checks present at the boundary that enforces them

---

## Deployment

- [ ] Migrations are safe — reversible, non-blocking, sharding-aware (per
  [`../architecture/sharding.md`](../architecture/sharding.md))
- [ ] Feature toggles configured if the
  [safe-update strategy](safe_update_strategy.md)
  calls for one
- [ ] Monitoring / alerts configured if new metrics are emitted
- [ ] Rollback plan documented in the design doc or the MR description

---

## Important notes

1. **Product provides WHAT / WHO, Dev provides HOW / WHERE.** Product defines
   requirements and users; Dev determines the technical approach and where
   the code lives.
2. **Architecture Planning lives with Dev.** The Dev team considers code
   duplication, maintainability, and placement before code is written — not
   during review.
3. **Implementation structure does not need to mirror UI structure.** A
   single backend service can power three UI surfaces; three separate
   services rarely need to mirror one screen.

---

## Related

- [user_stories.md](user_stories.md) — acceptance-criteria format
- [task_breakdown.md](task_breakdown.md) — sizing and slicing
- [tech_design.md](tech_design.md) — design-doc rules
- `../../skills/planning/SKILL.md` — `/planning` skill
