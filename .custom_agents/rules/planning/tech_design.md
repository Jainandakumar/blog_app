---
last_reviewed: 2026-05-19
---

# Technical design documents

The template and rules for technical design documents. Use this whenever a
Feature or Story needs a written design before implementation begins.

---

## When to write one

Write a technical design doc for:

- New features that span multiple components
- Significant refactorings
- Database schema changes (new tables, non-trivial column changes)
- New APIs or third-party integrations
- Performance-critical features
- Security-sensitive features

Skip it for one-line tweaks, copy changes, or work fully contained within a
single existing class. When in doubt, write at least the Overview, Goals, and
Design sections — they're cheap insurance.

---

## Where it lives

- During planning: under `.workspace/[FEATURE_KEY]/tech_design.md` (the
  planning skill's workspace folder; gitignored).
- After approval and once code lands: as a feature doc under
  `docs/features/<feature_slug>.md` per the feature-docs frontmatter rules
  in [`../meta/frontmatter_specs.md`](../meta/frontmatter_specs.md).

---

## Template

```markdown
# Feature Name

## Overview
Brief description of the feature and its purpose.

## Goals
- What we're trying to achieve
- Success criteria

## Non-Goals
- What we're explicitly NOT doing in this iteration

## Background
- Context and motivation
- Related features or systems
- Links to tickets, discussions, or related docs

## Design

### Database Changes
- New tables
- Schema modifications
- Indexes
- Data migrations

### API Changes (if applicable)
- New endpoints
- Request/response formats
- Authentication/authorization

### Business Logic
- Service objects
- Models and validations
- State machines (if applicable)

### UI Changes (if applicable)
- Mockups or wireframes
- User flows

### Error Handling
- Expected error conditions
- How errors are surfaced to users
- Logging and monitoring

## Security Considerations
- Authentication/authorization requirements
- Data protection
- Input validation
- Potential vulnerabilities

## Performance Considerations
- Expected load
- Caching strategy
- Database query optimization
- Background job usage

## Testing Strategy
- Unit tests
- Integration tests
- Manual testing checklist

## Rollout Plan
- Feature flags (if applicable)
- Phased rollout strategy
- Rollback plan

## Open Questions
- Unresolved decisions
- Areas needing clarification

## Alternatives Considered
- Other approaches considered and why they were rejected

## Timeline
- Estimated effort
- Milestones

## References
- Links to related docs, tickets, designs
```

---

## Section-by-section rules

- **Non-Goals are required when scope is contested.** If you've heard
  "shouldn't this also do X?" during scoping, list X under Non-Goals so the
  reviewer doesn't ask again.
- **Open Questions ship with the doc.** Don't withhold publication until every
  question is answered — surfacing the questions IS the doc's job.
- **Alternatives Considered prevents re-litigation.** Future maintainers will
  ask "why didn't we just …?" Capture rejected alternatives now.
- **Rollout Plan covers rollback.** Every doc that ships behaviour change must
  document how to roll back. Pair with the
  [safe-update strategies](safe_update_strategy.md)
  the planning skill selects.

---

## Related

- [user_stories.md](user_stories.md) — Stories that pair with this design
- [task_breakdown.md](task_breakdown.md) — how to slice the design into work
- [completion_checklist.md](completion_checklist.md) — "as-built" notes on
  the design doc are part of the done definition
- `../meta/frontmatter_specs.md` — feature-doc frontmatter once the design
  graduates from workspace to `docs/features/`
