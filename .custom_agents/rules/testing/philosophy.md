---
paths:
  - "spec/**"
last_reviewed: 2026-05-19
---

# Testing philosophy

## Core Principles

1. **Tests document the guarantees we commit to** — They specify exactly what functionality we promise our code will deliver.
2. **Tests enable refactoring** — Well-tested code can be safely refactored.
3. **Fast tests enable rapid development** — Slow tests discourage running them.
4. **Test behavior, not implementation** — Tests should survive refactoring.

## What Tests Document

**Tests put into the codebase exactly what we commit that the code will do.**

Think about guarantees:

- If you use the PLUS operator between two integers, it returns the total combined → Ruby guarantees this.
- If you use the PLUS operator between two `User` objects → Do WE guarantee behavior? If yes, test it. If no (we delegate to Ruby), don't test it.

### Examples

**Guarantee: precision tolerance for float addition**

```ruby
# Do we guarantee that adding two floats returns exactly 2.0?
# Or do we guarantee they're within a finite precision?
# If the guarantee is "within tolerance," write ONE test for that guarantee.
# Don't test every possible pair of floats (infinity tests).

it "adds floats within tolerance" do
  result = calculator.add(1.1, 0.9)
  expect(result).to be_within(0.001).of(2.0)
end
```

**Don't test Ruby/framework internals (brittle):**

```ruby
# Bad - testing Ruby's behavior, not our guarantee
it "raises TypeError when adding User objects" do
  expect { user1 + user2 }.to raise_error(TypeError)
end
# This could break with Ruby version changes even though our code didn't change.
# Only test this if YOU explicitly raise TypeError (your guarantee).
```

**Keep tests that provide substantial benefit:**

- Even if tests seem similar, if they provide substantial benefit (catching different edge cases, documenting different scenarios), keep them.
- Use judgment: Does this test document a guarantee we make? Does it provide value?

## What to Test

**DO test:**

- Business logic and domain rules
- Edge cases and error conditions
- Security-critical code
- Complex algorithms and calculations
- Integration points
- Public APIs

**DON'T test:**

- Third-party library internals
- Framework magic (Rails associations, validations work)
- Private methods in isolation (test through public interface)
- Trivial getters/setters

## The YARD comment IS the contract

Each public method's YARD comment defines its testable contract:

- `@param` declarations specify accepted input types
- `@return` declares the output type
- `@raise` declares expected exceptions

**Tests verify what YARD says, not what implementation does internally.**

### Test what's documented; don't test what isn't

If code accommodates `User OR nil`, the method's YARD comment MUST
declare it (`@param [User, nil]`) — and we test both cases.

If YARD says only `@param [User]`, we don't test what happens with
`Organization`, with `nil`, or with any other type.

**Exception**: code may have an explicit branch for an undocumented
type (e.g., `raise unless user.is_a?(User)`). For branch coverage,
test ONE non-User case (any type triggers the branch). Don't
enumerate types — the test exists to execute the conditional,
not to verify behavior across many types.

### Coverage definition

"Full coverage" means **every condition on every line executed** —
branch coverage, not permutation coverage.

If a method has multiple meaningful input permutations (e.g., User
in different states, different active flags), those permutations are
tested **upstream** where the contract for each permutation is
documented. Not in the downstream method's tests.

### Minimal tests, fast tests

Write only enough tests to:
1. Cover all YARD-documented contract cases.
2. Execute every condition on every line.

Test suite speed is a first-class design goal. Each new test should
add information not already covered. Duplicating coverage slows the
suite without adding value.

### Test your contract, not the contracts of methods you call

Verify what YOUR method commits to in YOUR YARD. Don't verify
behavior produced by called methods — that's their contract, tested
in their spec.

If you want a behavior to be testable in your method, write it
explicitly in your code (e.g., explicit `raise`) rather than relying
on a called method's implementation. Otherwise your tests couple to
code you didn't write — a refactor in someone else's file breaks
your test. See [`../design/testability_signals.md`](../design/testability_signals.md)
"Test your contract, not the contracts of methods you call" for the
full treatment with examples.

## Related

- [`requirements.md`](requirements.md) — Mandatory rules including "never rewrite tests to make them pass."
- [`test_objects.md`](test_objects.md) — Detroit-school TDD: prefer real collaborators over mocks.
- [`structure.md`](structure.md) — Translating these principles into well-structured specs.
- [`../design/testability_signals.md`](../design/testability_signals.md) —
  When YARD authoring is awkward, that friction signals a design
  problem. Refactor before writing tests that paper over a flawed
  contract.
