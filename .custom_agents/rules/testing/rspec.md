---
paths:
  - "spec/**"
last_reviewed: 2026-05-19
---

# RSpec basics

## RSpec is Our Primary Test Framework

- **Location:** `spec/` directory.
- **Configuration:** `spec/rails_helper.rb`, `spec/spec_helper.rb`.
- **Support files:** `spec/support/`.

## Legacy Test::Unit

- **Location:** `test/` directory.
- **Status:** Being phased out — do not add new Test::Unit tests.
- **Migration:** Convert to RSpec when touching legacy tests.

## Basic RSpec Structure

```ruby
RSpec.describe User do
  describe "#full_name" do
    context "when first and last name are present" do
      let(:user) { User.new(first_name: "John", last_name: "Doe") }

      it "returns the concatenated name" do
        expect(user.full_name).to eq("John Doe")
      end
    end

    context "when last name is missing" do
      let(:user) { User.new(first_name: "John", last_name: nil) }

      it "returns only the first name" do
        expect(user.full_name).to eq("John")
      end
    end
  end
end
```

## Recommended Gems

- **rspec-rails** — RSpec for Rails.
- **factory_bot_rails** — Test data factories.
- **faker** — Generate fake data.
- **shoulda-matchers** — One-liner matchers for validations/associations.
- **webmock** — Stub HTTP requests.
- **vcr** — Record and replay HTTP interactions.
- **capybara** — Browser simulation for feature tests.
- **database_cleaner** — Clean database between tests.
- **simplecov** — Code coverage.

See `Gemfile` for installed testing gems.

## Related

- [`structure.md`](structure.md) — `describe`/`context`/`it` conventions and style.
- [`test_types.md`](test_types.md) — Choosing between unit, request, and feature specs.
- [`../architecture/tests.md`](../architecture/tests.md) — Where spec files live in the repo.
