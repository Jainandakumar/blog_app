---
paths:
  - "spec/**"
last_reviewed: 2026-05-19
---

# Test structure and style

How to organize the body of a spec file: `describe`/`context`/`it` blocks, setup with `let`/`let!`, assertion granularity, and overall style.

## Use Descriptive Names

```ruby
# Good
describe "#calculate_premium" do
  context "when subscriber is under 30" do
    it "applies the young adult discount" do
    end
  end
end

# Bad
describe "method" do
  it "works" do
  end
end
```

## Organize with describe / context

- **`describe`** — For classes and methods.
- **`context`** — For different scenarios/conditions.

```ruby
RSpec.describe Calculator do
  describe "#calculate" do
    context "with valid input" do
      it "returns the result" do
      end
    end

    context "with invalid input" do
      it "raises an error" do
      end
    end
  end
end
```

## Use let / let! for Setup

```ruby
# Good - lazy evaluation
let(:user) { create(:user) }
let(:plan) { create(:benefit_plan) }

# Good - immediate evaluation when needed
let!(:existing_record) { create(:enrollment) }

# Bad - setup in before block for simple cases
before do
  @user = create(:user)
  @plan = create(:benefit_plan)
end
```

## One Assertion Per Test (Prefer)

```ruby
# Good - focused
it "sets the user name" do
  expect(user.name).to eq("John Doe")
end

it "sets the user email" do
  expect(user.email).to eq("john@example.com")
end

# Acceptable - related assertions
it "creates a valid enrollment" do
  expect(enrollment).to be_persisted
  expect(enrollment.status).to eq("active")
end

# Bad - unrelated assertions
it "does many things" do
  expect(user.name).to eq("John")
  expect(plan.cost).to eq(100)
  expect(enrollment.active?).to be true
  expect(email_sent?).to be true
end
```

## Test Style Guidelines

### Follow Style Guide

- Tests should follow the same style rules as application code.
- Use descriptive test names.
- Keep tests focused and simple.
- Avoid complex setup.

### Guidelines, Not Absolutes

While "NEVER rewrite tests" (see [`requirements.md`](requirements.md)) is a strong guideline, there are legitimate exceptions. Use judgment and document your reasoning in PRs.

### CODEOWNERS

Check CODEOWNERS before modifying tests written by others — they may have important context.

## Related

- [`rspec.md`](rspec.md) — Framework basics and the canonical spec layout.
- [`test_types.md`](test_types.md) — Choosing the right type of spec for what you're testing.
- [`factories.md`](factories.md) — Test data setup that pairs with `let` blocks.
- [`test_objects.md`](test_objects.md) — When to reach for `let(:user) { create(:user) }` vs. `instance_double`.
- [`requirements.md`](requirements.md) — The "never rewrite tests" rule referenced above.
