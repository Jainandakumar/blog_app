---
last_reviewed: 2026-05-19
---

# Task breakdown rules

How to slice a Feature or design into reviewable Story / ticket-sized tasks.
The principles here govern the `/planning` skill's breakdown step and any
manual decomposition done outside the skill.

---

## Principles

1. **Small, reviewable chunks.** Aim for merge requests that can be reviewed
   in under 30 minutes. A reviewer who runs out of attention rubber-stamps the
   rest — splits keep review honest.
2. **Vertical slices.** Each task should deliver value end-to-end (model +
   service + controller + view + tests, scoped to the slice) rather than
   "all the models, then all the controllers." Vertical slices are
   independently shippable; horizontal layers leave half-finished features in
   `main`.
3. **Independent tasks.** Minimise blocking dependencies. If task B can be
   started in parallel with task A, that's better than B depending on A.
4. **Testable increments.** Every task ships with tests for what it adds or
   changes. "Tests later" is a Story smell — split the test work into its
   own task only when the test framework itself is being built.

These principles drive sizing: a Story that violates more than one principle
is too big and should be split.

---

## Example breakdown

**Feature:** Bulk enrollment upload

**Tasks:**

1. Database: Add `bulk_enrollment_imports` table
2. Model: Create `BulkEnrollmentImport` model with validations
3. Service: Implement CSV parsing service
4. Service: Implement enrollment creation service
5. Job: Create background job for processing imports
6. Controller: Add upload endpoint
7. View: Create upload form
8. Tests: Add model tests
9. Tests: Add service tests
10. Tests: Add integration tests
11. Docs: Update API documentation
12. Docs: Add user guide

Note: the example above lists tests as separate tasks for illustration. In
practice prefer to ship each model/service/controller task **with its tests
in the same merge request** (per "Testable increments"). Standalone
test-only tickets are reserved for retrofitting coverage on legacy code.

---

## Task template

Use this template when authoring a ticket description by hand (the `/planning`
skill produces a richer brief; the template here is for manual use).

```markdown
## Task: [Brief Description]

### Description
Clear description of what needs to be done.

### Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Tests written and passing
- [ ] Documentation updated

### Files to Change
- `app/models/bulk_enrollment_import.rb`
- `db/migrate/...rb`
- `spec/models/bulk_enrollment_import_spec.rb`

### Dependencies
- Blocks: Task #123
- Blocked by: Task #456

### Estimate
2-4 hours

### Notes
Any additional context or considerations.
```

---

## GitHub issue template

For tickets entered directly into GitHub Issues (not Jira). Use Jira's UI for
Jira tickets — the `/planning` skill handles the ADF formatting.

```markdown
## Title: Add bulk enrollment CSV upload

### Description
As a  administrator, I need to upload enrollments via CSV to quickly
enroll many employees.

### Acceptance Criteria
- [ ] Can upload CSV file
- [ ] Valid enrollments are created
- [ ] Errors are reported clearly
- [ ] Process runs in background
- [ ] Email confirmation sent

### Technical Notes
- Validate CSV format before processing
- Limit file size to 10MB
- Support up to 1000 enrollments per file

### Related
- Blocks #456
- Related to #123

Labels: ~feature ~enrollment ~high-priority
Milestone: Sprint 4.1
Assignee: @developer
```

---

## Task-management practices

- One concrete deliverable per ticket. "Improve performance" is a Feature, not
  a Story.
- Clear, descriptive titles. The title alone should tell the reader what the
  ticket does.
- Link related tickets explicitly. `Blocks` / `Blocked by` / `Related to`.
- Assign to a person, not a group, when work starts. Group ownership is for
  backlog grooming.
- Update status as the work moves. A stale ticket is worse than no ticket.

---

## Related

- [user_stories.md](user_stories.md) — the user-facing format
- [tech_design.md](tech_design.md) — the design that informs the breakdown
- [completion_checklist.md](completion_checklist.md) — "done" definition
- `../../skills/planning/SKILL.md` — automated breakdown via `/planning`
