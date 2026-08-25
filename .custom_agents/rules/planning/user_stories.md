---
last_reviewed: 2026-05-19
---

# User stories and acceptance criteria

The canonical format for User Story tickets in Jira and any planning artefact
that captures user-facing scope. Use this format whenever you write or review a
Story brief, a Feature description, or a backlog item.

---

## Format

```
As a [user type]
I want [goal]
So that [benefit]
```

Three lines. Each line answers a different question and the wording matters:

- **`As a [user type]`** — the role that . Be specific. "As a 
  administrator" is better than "As a user." If multiple roles benefit, pick
  the primary one and add the others to acceptance criteria or notes.
- **`I want [goal]`** — what the role can do that they cannot do today. Phrase
  in active voice, present tense.
- **`So that [benefit]`** — the *why*. The value that justifies the work. If
  this line is hard to write, the story might not be worth doing.

### Example

```
As a  administrator
I want to bulk upload subscriber enrollments via CSV
So that I can quickly enroll many employees at once
```

---

## Acceptance criteria

Every Story needs concrete acceptance criteria. Use Given/When/Then phrasing —
it forces a precondition, an action, and an observable outcome.

### Format

```
Given [context]
When [action]
Then [expected outcome]
```

Each criterion is independently verifiable. Stack additional `And` lines under
`Then` when several outcomes follow the same trigger.

### Example

```
Given I am a  administrator
When I upload a valid CSV with 100 enrollments
Then all 100 enrollments are created
And I see a success message
And I receive an email confirmation

Given I upload a CSV with invalid data
When the file contains errors
Then no enrollments are created
And I see error messages for each invalid row
```

---

## When to write multiple stories

If a single user story produces several distinct user-visible behaviours, split
it. Each Story should be testable as a unit and shippable independently. See
[task_breakdown.md](task_breakdown.md) for the size and slicing rules that
govern when to split.

---

## Related

- [task_breakdown.md](task_breakdown.md) — sizing and slicing
- [tech_design.md](tech_design.md) — the design doc that often accompanies a
  Story or Feature
- [completion_checklist.md](completion_checklist.md) — the "done" definition
- `./skills/planning/SKILL.md` — the `/planning` skill that creates
  Stories from a Feature
