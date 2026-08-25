---
paths:
  - "spec/**"
last_reviewed: 2026-05-19
---

# Test requirements

Mandatory rules. Violations are merge-blocking unless explicitly noted.

## All Tests Must Live in `spec/` (Critical)

All new and updated tests **must** be placed in the main `spec/` directory — not in `components/*/spec/`, `engines/*/spec/`, or any other location.

- **New specs:** Create in `spec/models/`, `spec/controllers/`, `spec/requests/`, etc.
- **Updating an existing spec outside `spec/`:** Move it into `spec/` as part of your change.
- **No exceptions.** Component and engine spec directories are legacy locations being consolidated.

**Code Review:** Violations are **Critical** (merge-blocking). Tests outside `spec/` will not be run in CI and fragment test coverage.

For the broader directory structure, see [`../architecture/tests.md`](../architecture/tests.md).

## All New Code Must Have Tests

- **Models:** Unit tests for validations, scopes, methods.
- **Controllers:** Request specs for all actions.
- **Services:** Unit tests for all public methods.
- **APIs:** Request specs with example requests/responses.
- **Background Jobs:** Unit tests for job execution.
- **Lib code:** Unit tests for all modules.

## Coverage Target

- **Minimum:** 70% overall coverage (enforced by SimpleCov).
- **Goal:** 80%+ for new code.
- **Critical paths:** 100% (authentication, payments, compliance).

See `.simplecov` configuration in project root.

### SimpleCov Configuration

Coverage is tracked by SimpleCov and configured in `.simplecov`:

```ruby
SimpleCov.start "rails" do
  add_filter "/spec/"
  add_filter "/test/"
  minimum_coverage 70
end
```

### Checking Coverage

```bash
# Run tests with coverage
rspec

# View coverage report
open coverage/index.html
```

### Coverage Exemptions

Some files can be excluded from coverage:

- Configuration files (`config/`)
- Database migrations
- Test support files

Document exemptions in `.simplecov`.

## Testing Legacy Code

When modifying existing code that has low or no test coverage:

- **DO:** Add tests for YOUR new/changed functionality.
- **DON'T:** Feel obligated to test unchanged legacy code.
- **If file has <50% coverage AND you're making substantial changes:** Aim to improve toward 70%.
- **If file has >70% coverage:** Maintain or improve it.

## NEVER Rewrite Tests to Make Them Pass

**Critical guideline:** If a test fails after your code change, **fix the code, not the test.**

**Why:**

- Test failure = your code broke something OR revealed a misunderstanding.
- Rewriting tests to pass = hiding bugs.
- Tests are the specification — if they fail, the spec isn't being met.

### When you CAN modify tests

1. **The test had a legitimate bug** (tested wrong behavior)
   - Document why the original test was incorrect.
   - Get review on the test change.

2. **The test was testing the wrong thing** (not the actual requirement)
   - Confirm with team/product that requirement changed.
   - Document what changed and why.

3. **Requirements explicitly changed** (business logic updated)
   - Link to ticket/discussion showing requirement change.
   - Update test to reflect new requirement.
   - Consider if this is a breaking change.

### Process when a test fails

1. **Understand WHY it's failing** — Read the test, understand what it expects.
2. **Check if your code is wrong** — 95% of the time, it is.
3. **If test seems wrong** — Ask team before changing.
4. **Document any test changes** — Clear commit message explaining why.

### CODEOWNERS Integration

- If you're breaking someone else's tests, check CODEOWNERS.
- Coordinate with code owner before changing their tests.
- They may know context about why the test exists.

### Example: good reason to modify a test

```ruby
# Old test (wrong)
it "calculates premium without taxes" do
  expect(calculator.premium).to eq(100.00)
end

# New test (correct - requirement always included taxes)
it "calculates premium including taxes" do
  expect(calculator.premium).to eq(110.00)
end

# Commit: "MDP-123456 Fix premium calculation test - requirement always included taxes"
```

### Example: bad reason

```ruby
# Your code changed behavior, test caught it.
# DON'T change the test — fix your code.
```

## Related

- [`philosophy.md`](philosophy.md) — Why tests exist and what they document.
- [`running.md`](running.md) — How to run tests when one fails.
- [`../architecture/tests.md`](../architecture/tests.md) — Where test files live.
