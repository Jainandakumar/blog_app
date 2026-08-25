---
paths:
  - "spec/**"
last_reviewed: 2026-05-20
---

# Running tests

Operational commands for running tests and Pronto. **How** to author tests
lives in the rest of [`../testing/`](../). This file is just commands.

## CRITICAL: Test Suite Reality

**RSpec:**

- **Full suite takes HOURS** — do NOT run the full suite locally.
- **Run related tests only** — use the changed-files script or targeted paths.
- **CI runs the full suite** — let CI handle comprehensive testing.

**Minitest (legacy):**

- **CAN run full suite locally** with:

  ```bash
  bundle exec rake --rakefile Rakefile.norails ci:unit
  ```

- Use when touching legacy code.

## Run Targeted RSpec Tests

```bash
# Single file (RECOMMENDED for local development)
bundle exec rspec spec/models/user_spec.rb

# Single test by line number
bundle exec rspec spec/models/user_spec.rb:42

# Directory (multiple files in one area)
bundle exec rspec spec/models/

# By pattern
bundle exec rspec spec/models/**/*_spec.rb
```

### Run with options

```bash
# Documentation format
bundle exec rspec --format documentation

# Fail fast (stop on first failure)
bundle exec rspec --fail-fast

# Only run failed tests
bundle exec rspec --only-failures

# With coverage
COVERAGE=true bundle exec rspec
```

### Parallel testing

```bash
bundle exec parallel_rspec spec/
```

## Find Related Tests (`rspec-changed` Script)

Use the `rspec-changed` script to find and run tests related to your changes:

```bash
# Run RSpec tests for files changed in current branch vs develop
bundle exec bin/rspec-changed
```

**What it does:**

- Compares your branch to develop (committed and uncommitted changes).
- Finds corresponding spec files for changed code.
- Automatically runs the related specs.

**How it maps files to specs:**

- `app/models/user.rb` → `spec/models/user_spec.rb`
- `app/controllers/enrollments_controller.rb` → `spec/controllers/enrollments_controller_spec.rb`
- `lib/enrollment/processor.rb` → tries `spec/models/enrollment/processor_spec.rb`, then `spec/lib/enrollment/processor_spec.rb`

## Test::Unit (legacy)

```bash
bundle exec rake test

# Specific test
bundle exec rake test TEST=test/unit/user_test.rb
```

## Code style — Pronto

**Use Pronto, NOT plain rubocop.** Full rubocop takes 40 minutes and surfaces
5,000+ existing errors; Pronto restricts to changed lines only.

```bash
# Run Pronto on changed lines only
bundle exec pronto run --commit=origin/develop --runner=rubocop

# With multiple runners
bundle exec pronto run --commit=origin/develop \
  --runner=rubocop --runner=rubycritic --runner=brakeman

# Auto-fix violations (RuboCop only)
bundle exec rubocop -a $(git diff --name-only origin/develop)
```

**Why Pronto:**

- Only scans changed lines
- Fast (seconds vs. 40 minutes)
- Codebase has 5,000+ existing violations
- We only validate new/changed code

Pronto also enforces YARD documentation cops on the MR diff. See
[`../yard/README.md`](../yard/README.md).

## CI

Tests run automatically in GitHub CI on every push. Check `.github-ci.yml`
for configuration.

```yaml
rspec:
  script:
    - bundle exec rspec --format progress
```

## Speed Up Tests

- Use `let` instead of `before` blocks.
- Use `build` instead of `create` when persistence isn't needed.
- Use transactional fixtures (default in RSpec).
- Run tests in parallel.
- Use spring for faster boot: `spring rspec`.

## Related

- [`requirements.md`](requirements.md) — Coverage targets and the "never rewrite tests" rule when one fails.
- [`structure.md`](structure.md) — `let` vs `before` patterns referenced under Speed Up Tests.
- [`../architecture/tests.md`](../architecture/tests.md) — Where test files live so you know what path to target.
- [`../yard/README.md`](../yard/README.md) — Pronto's YARD cops.
- [`../style/linters.md`](../style/linters.md) — Standalone linter commands.
