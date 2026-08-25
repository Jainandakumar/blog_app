---
last_reviewed: 2026-05-19
---

# Development session UX patterns

When and how the main session prompts the user about commits, MRs, branches,
and incomplete-feature strategies. Git mechanics (branching, commit format,
push/MR creation) are in [git.md](git.md), [commits.md](commits.md), and
[merge_requests.md](merge_requests.md). This file is the **prompt templates**
that govern the conversation.

## Branch checks

Before any code change, confirm you're not on a protected branch.

```
I notice you're on the [branch] branch. Let me create a feature branch before we start development.
Would you like me to create branch MDP-NNNNNN_brief_description now?
```

Protected branches (NO direct commits): `develop`, `rc-patches`, `master`,
`release-*`. See [git.md](git.md) for the full strategy.

## Auto-commit prompt (once per session)

```
As we work, I can automatically commit code at logical breakpoints (after each method, completed file, or test).
This helps maintain a clean commit history. Is automatic committing okay for this session?
```

If approved, commit at logical breakpoints — see "When to commit" below.

## When to commit (if auto-commit approved)

- After completing a full method (with tests if applicable)
- After completing a full file update
- After adding a new model with tests
- After creating AND running a database migration (commit migration + schema.rb together)
- After fixing each bug in a multi-bug session
- At any logical breakpoint where code is stable

## MR size targeting (~300 lines)

Target ~300 lines per MR. Start watching at ~200 lines.

### At ~250–300 lines

```
We've completed [component]. This is a good breaking point for an MR because:
- [Reason 1]
- [Reason 2]

Would you like me to push this branch and create an MR?
```

### Mid-feature approaching limit

```
We're approaching 300 lines of changes. To keep MRs reviewable, we could:
1. Complete the current [component] and create an MR (~X lines)
2. Split the remaining work into a separate MR

Which would you prefer?
```

## Large features — break down proactively

```
This feature has several components. To help you merge code daily, we could break it into smaller MRs:

**MR 1: Database schema and models** (Day 1)
- Migration for table
- Model class with validations
- Model unit tests

**MR 2: Service layer** (Day 2)
- Service class
- Business rules
- Service tests

[etc.]

Would you like to work this way?
```

## Stacked MRs (dependent work)

```
Since the next work depends on these changes, I can create a stacked MR:
1. Push current branch and create MR for review
2. Create a new branch FROM this branch (not from develop)
3. Continue development on the new branch

Later, after the first MR merges, we'll rebase the second branch onto develop.

Would you like me to set up stacked branches?
```

See [git.md](git.md) §Stacked MR workflow for the mechanics.

## Incomplete features — strategies for merging

Options for merging incomplete work:

1. **Feature toggle (preferred for user-visible features).** See
   `./rules/architecture/feature_toggle.md` for the `PlanSource::FeatureToggle` gem.
   ```ruby
   if PlanSource::FeatureToggle[:new_feature].enabled?(user)
     # new code path
   else
     # existing code path
   end
   ```
2. **Unwired code.** Classes/methods that exist but aren't called yet.
3. **Dark deploy.** Code deployed but no access points (no routes, no UI).

## When NOT to suggest an MR

- User just created an empty class or single method.
- User explicitly said more instructions are coming.
- Work is clearly incomplete (controller written but no tests).
- Very minimal work.

## Technical debt — fix immediately

**Fix during this session:**
- Pronto violations on lines you changed.
- Failing tests.

**Process:**
1. Make code changes.
2. Run Pronto: `bin/pronto run -c origin/develop`.
3. Fix violations.
4. Run related tests: `bundle exec bin/rspec-changed`.
5. Fix any failures.

**Do NOT:**
- Run full rubocop (40 minutes, 5k+ errors).
- Fix violations in code you didn't touch.

## Related

- [git.md](git.md) — branching, agent ownership, deployment flows
- [commits.md](commits.md) — commit-message format and frequency
- [merge_requests.md](merge_requests.md) — MR creation mechanics
