---
paths:
  - "**/*.rb"
last_reviewed: 2026-05-21
---

# YARD authoring rules

When you write or modify a public Ruby method, document it with YARD using the
rules below. Private methods don't need YARD — use a plain `#` comment when
the *why* is non-obvious. Specs (`spec/`, `test/`) and migrations
(`db/migrate/`) don't need YARD.

For the `@see` tag (linking code to feature docs in `docs/features/`) and the
bidirectional `@see` ↔ `paths:` check, see [cross_references.md](cross_references.md).

## Tag set

Use only these five tags. Other YARD tags exist; ignore them unless a future
rule adds them.

| Tag | Documents |
|---|---|
| `@param [Type] name description` | A method parameter |
| `@return [Type] description` | The method's return value |
| `@raise [ErrorClass] when raised` | An exception callers are expected to handle |
| `@example optional caption` | A typical usage example (body indented below) |
| `@see <path> <description>` | A cross-reference to documentation outside this file (typically a feature doc). The trailing description is required — without it YARD renders the path twice in HTML output. See [cross_references.md](cross_references.md). |

## Required content by element

| Element | Description | `@param` | `@return` | `@raise` |
|---|---|---|---|---|
| Class / module | Required (1+ sentence) | — | — | — |
| Public instance method | Required | One per parameter | Required | If raised |
| Public class method | Required | One per parameter | Required | If raised |
| `initialize` | Optional | One per parameter | **Omit** | If raised |
| `attr_reader` / `attr_accessor` | Optional | — | Encouraged | — |

Private methods need no YARD. If a private method encodes a non-obvious
business rule, write a regular `#` comment explaining the *why* — not YARD
tags.

## Type formatting

Prefer structured types when the value has structure:

- `Hash{Symbol => BigDecimal}`, not bare `Hash`
- `Array<String>`, not bare `Array`
- `Array<Hash{Symbol => Object}>` for arrays of structured hashes
- Nilable: `[Foo, nil]`
- Union: `[Foo, Bar]`

Use the actual class name, not the generic concept:

- `BigDecimal`, not `Decimal`
- `ActiveSupport::TimeWithZone`, not `Time` if that's what's actually returned

## `@example` blocks

Include an `@example` when:

- The class's typical usage isn't obvious from the constructor signature
- A method's return shape can't be inferred from `@return [Type]` alone

Format:

    # @example Short caption describing the scenario
    #   instance = MyClass.new(arg)
    #   result   = instance.method(input)
    #   result.to_s # => "342.18"

Two-space indent under the `@example` line. Captions are optional but help
when a class has several distinct usage patterns. Use `# =>` (with the space
before `=>`) to show return values inline.

## Canonical example

```ruby
# frozen_string_literal: true

module BenefitPlans
  # Calculates a subscriber's monthly premium for a given benefit plan.
  #
  # @example Calculate a premium for a new enrollment
  #   calculator = BenefitPlans::PremiumCalculator.new(plan)
  #   calculator.calculate(subscriber).to_s # => "342.18"
  class PremiumCalculator
    class << self
      # Convenience constructor that calculates the premium in a single call.
      #
      # @param plan [BenefitPlan] the plan being priced
      # @param subscriber [Subscriber] the person enrolling
      # @return [BigDecimal] the monthly premium amount
      # @raise [InvalidPlanError] if the plan is not active for the subscriber's effective date
      def calculate_for(plan, subscriber)
        new(plan).calculate(subscriber)
      end
    end

    # @return [BenefitPlan] the plan this calculator is bound to
    attr_reader :plan

    # @param plan [BenefitPlan] the plan being priced
    def initialize(plan)
      @plan = plan
    end

    # Returns the monthly premium for the given subscriber.
    #
    # @param subscriber [Subscriber] the person enrolling
    # @return [BigDecimal] the monthly premium amount, rounded to two decimal places
    # @raise [InvalidPlanError] if the plan is not active for the subscriber's effective date
    def calculate(subscriber)
      # ...
    end

    private

    def apply_age_band(amount, age)
      # ...
    end
  end
end
```

## When YARD authoring is awkward

If writing the YARD for a method feels forced — the return value
can't capture the most important effect, the parameters span
unrelated classes, or the contract enumerates several behaviors —
that's a design signal. See
[`../design/testability_signals.md`](../design/testability_signals.md).
Refactor the design before relaxing the YARD.

## Verification

`bin/pronto run -c origin/develop` runs `Style/Documentation`,
`Style/DocumentationMethod`, and `rubocop-yard` on the MR diff. Tag-syntax
mistakes (`@returns` typos, missing `[Type]`, undocumented `@raise` after a
`raise`) are caught there. Run it before pushing.
