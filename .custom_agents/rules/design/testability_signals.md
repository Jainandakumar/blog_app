---
paths:
  - "**/*.rb"
last_reviewed: 2026-06-09
---

# Testability friction as a design signal

When writing the YARD comment for a method is awkward — the return
value can't capture the most important effect, the parameters span
unrelated classes, or the contract has to enumerate several
behaviors — that friction is usually a **design signal**, not a
documentation problem.

Refactor the design before relaxing the YARD or writing tests that
paper over the contract.

## Friction Pattern 1: silent side effects

If a method creates or modifies a record that isn't reflected in its
return value, callers can't reason about what the method did from
the contract, and tests can't verify the effect through the YARD
spec.

```ruby
# Awkward — what does this return? Why?
# @param coverage_level_id [Integer]
# @return [Subscriber]
class Subscriber
  def enroll_in_coverage(coverage_level_id)
    Coverage.create!(subscriber: self, coverage_level_id: coverage_level_id)
    self
  end
end
```

The Coverage record is created silently. Fix the return to reflect
what was created:

## Friction Pattern 2: method on the wrong class

When a method on class A primarily acts on class B (creates B,
modifies B, returns B), the method probably belongs on B. Leaving
it on A typically violates Law of Demeter / Dependency Inversion.

```ruby
# Better return shape — but the method may still be on the wrong class.
# @param coverage_level_id [Integer]
# @return [Coverage] the newly created enrollment
class Subscriber
  def enroll_in_coverage(coverage_level_id)
    Coverage.create!(subscriber: self, coverage_level_id: coverage_level_id)
  end
end
```

### Implement in the correct class

```ruby
# DO — method lives on the class that owns the entity
# @return [Coverage]
class Coverage
  def self.new_subscriber_coverage_for_level(subscriber, coverage_level)
    create!(subscriber: subscriber, coverage_level: coverage_level)
  end
end
```

## Friction Pattern 3: compound operations compose public single-action methods

When a workflow does multiple things (e.g., "swap coverage" =
terminate current Coverage + create new Coverage), the compound
operation lives in a workflow/business class. Each individual unit
stays on the entity class as a public testable interface.

```ruby
# Coverage owns the units
class Coverage
  def terminate
    update(end_date: Date.today)
  end

  def self.new_subscriber_coverage_for_level(subscriber, coverage_level)
    create!(subscriber: subscriber, coverage_level: coverage_level)
  end
end

# A workflow class owns the compound
class Subscriber::Enrollment
  def initialize(subscriber)
    @subscriber = subscriber
  end

  # @return [Coverage] the new coverage after the swap
  # @raise [RuntimeError] if current_coverage can not be terminated
  def swap_coverage_to_new_level(current_coverage, new_level)
    current_coverage.terminate || raise "Failed to term coverage"
    Coverage.new_subscriber_coverage_for_level(@subscriber, new_level)
  end
end
```

The compound method's YARD describes its public effect (new Coverage
returned). Each unit is tested independently. The compound's tests
verify only the public contract, not the internal sequence.

### Test your contract, not the contracts of methods you call

The compound's tests verify what THIS method commits to in its own
YARD. They do NOT verify behavior produced by called methods —
that's the called method's contract, tested in the called method's
spec.

For `swap_coverage_to_new_level`, test:

- Returns a new `Coverage` on success
- Raises `RuntimeError` when `terminate` returns false (your YARD
  declares this; your code explicitly raises it)

Do NOT test:

- That `Coverage#terminate` actually wrote `end_date` to the
  database (Coverage's contract, in `coverage_spec.rb`)
- That `Coverage.new_subscriber_coverage_for_level` creates a
  record (also Coverage's contract — your test just verifies the
  return value is the new record)
- That an underlying `create!` would raise on validation failure
  (two frames away — ActiveRecord's contract, not yours)

### Make implicit guarantees explicit

If you want a behavior to be testable in your method, write it
explicitly in your code. Don't rely on a called method's
implementation.

```ruby
class Subscriber::Enrollment
  # DON'T — relies on Rails `!` convention raising; your test would
  # verify the raise but you didn't write the raise
  def swap_coverage_to_new_level(current_coverage, new_level)
    current_coverage.terminate!  # implicit raise from update!
    Coverage.new_subscriber_coverage_for_level(@subscriber, new_level)
  end

  # DO — raise explicitly so it's YOUR contract
  def swap_coverage_to_new_level(current_coverage, new_level)
    current_coverage.terminate || raise "Failed to terminate coverage"
    Coverage.new_subscriber_coverage_for_level(@subscriber, new_level)
  end
end
```

The explicit form: your YARD documents the raise, your code
produces it, your test verifies it. None of those couple to
Coverage's implementation.

**Why it matters**: testing transitive behavior couples your tests
to code you didn't write. If Coverage's author refactors
`terminate!` to return false instead of raising, your test of
`swap_coverage_to_new_level` breaks — even though your code is
unchanged. The fault line is in someone else's file.

## Recognizing the signals

If YARD authoring reveals any of these patterns, refactor before
writing tests:

- **Return type doesn't reflect the most important effect** → silent
  side effect (Pattern 1)
- **Method on class A primarily creates/modifies class B** → wrong
  class ownership (Pattern 2)
- **One method does several things; YARD must enumerate them** →
  compound that should compose units (Pattern 3)

Don't write tests to paper over a flawed contract. Refactor first;
the YARD becomes clean and the tests become natural.

## Related

- [`refactoring.md`](refactoring.md) — when and how to refactor in general.
- [`principles.md`](principles.md) — Explicit Over Implicit is the
  principle behind Pattern 1.
- [`solid.md`](solid.md) — SRP (single actor), DIP — patterns 2 and 3
  apply these.
- [`anti_patterns.md`](anti_patterns.md) — patterns explicitly forbidden.
- [`../yard/authoring.md`](../yard/authoring.md) — YARD authoring rules
  that produce the contract these signals read.
- [`../testing/philosophy.md`](../testing/philosophy.md) — "YARD is the
  contract" — the testing side of this same idea.
