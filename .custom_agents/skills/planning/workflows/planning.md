---
last_reviewed: 2026-05-19
---

# Feature lifecycle phases

The five high-level phases a Feature moves through, from "we should build
this" to "shipped and monitored." Use this as the mental map when scoping
work; the `/planning` skill's
[`planning_instructions.md`](../planning_instructions.md) covers the detailed
Jira-creation steps that fall under Phase 1 (Discovery) and Phase 2 (Design).

---

## Phase 1: Discovery

**Goals.** Understand the problem and the requirements.

**Activities.**

- Gather requirements from stakeholders.
- Review existing similar features.
- Identify impacted systems and components.
- Estimate complexity and effort.
- Identify risks and dependencies.

**Deliverables.**

- Feature brief or one-pager.
- User stories (format: [`../../../rules/planning/user_stories.md`](../../../rules/planning/user_stories.md)).
- Acceptance criteria.
- Initial effort estimate.

**Skill coverage.** `/planning` Step 1 (fetch Feature), Step 2 (codebase
research), Step 3 (external research).

---

## Phase 2: Design

**Goals.** Plan the technical implementation.

**Activities.**

- Design database schema changes.
- Plan API endpoints if applicable.
- Design service objects and business logic.
- Identify reusable components.
- Plan error handling and edge cases.
- Consider security implications (see [`../../../rules/security/`](../../../rules/security/)).
- Consider performance implications.

**Deliverables.**

- Technical design document (template:
  [`../../../rules/planning/tech_design.md`](../../../rules/planning/tech_design.md)).
- Database migration plan.
- API specification, if applicable.
- Component diagram, if helpful.
- Security review checklist.
- Story breakdown (rules:
  [`../../../rules/planning/task_breakdown.md`](../../../rules/planning/task_breakdown.md)).

**Skill coverage.** `/planning` Step 4 (safe-update strategy), Step 5
(breakdown), Step 6 (architecture overview), Step 7 (detailed briefs),
Step 8 (create in Jira).

---

## Phase 3: Implementation

**Goals.** Build the feature.

**Activities.**

- Create feature branch (per [`../../../rules/workflows/git.md`](../../../rules/workflows/git.md)).
- Write tests alongside code (per [`../../../rules/testing/`](../../../rules/testing/)).
- Implement in small, reviewable commits (per
  [`../../../rules/workflows/commits.md`](../../../rules/workflows/commits.md)).
- Follow code style guidelines (per [`../../../rules/style/`](../../../rules/style/)).
- Add YARD documentation (per [`../../../rules/yard/README.md`](../../../rules/yard/README.md)).
- Update relevant feature docs.

**Deliverables.**

- Working code.
- Tests (unit, integration, feature).
- Updated documentation.
- Merge request (per
  [`../../../rules/workflows/merge_requests.md`](../../../rules/workflows/merge_requests.md)).

**Skill coverage.** `/develop` — not part of `/planning`.

---

## Phase 4: Review

**Goals.** Ensure quality and correctness.

**Activities.**

- Code review (per [`../../code-review/SKILL.md`](../../code-review/SKILL.md)).
- QA testing.
- Security review for sensitive features.
- Performance testing for high-traffic features.
- Stakeholder demo, if applicable.

**Deliverables.**

- Approved merge request.
- QA sign-off.
- Updated changelog.

**Skill coverage.** `/code-review`, `/develop fix`.

---

## Phase 5: Deployment

**Goals.** Ship to production safely.

**Activities.**

- Merge to the main branch.
- Deploy to staging.
- Smoke-test in staging.
- Deploy to production.
- Monitor for errors.
- Verify in production.

**Deliverables.**

- Deployed feature.
- Deployment notes.
- Monitoring dashboards if new metrics were added.

**Skill coverage.** Outside the AI skill surface — handled by DevOps and the
deployment pipeline. The completion checklist
([`../../../rules/planning/completion_checklist.md`](../../../rules/planning/completion_checklist.md))
covers the pre-deployment gates.

---

## Related

- [`../SKILL.md`](../SKILL.md) — `/planning` orchestrator
- [`../planning_instructions.md`](../planning_instructions.md) — detailed
  Steps 1–8 the skill executes
- [`../../../rules/planning/`](../../../rules/planning/) — templates and
  conventions referenced above
