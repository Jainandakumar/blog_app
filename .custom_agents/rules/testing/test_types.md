---
paths:
  - "spec/**"
last_reviewed: 2026-06-30
---

# Test types

Pick the type that matches the boundary you're testing. When in doubt, prefer the lower-cost, more-focused option (unit > request > system).

## Unit Tests

**Purpose:** Test individual classes/methods in isolation.

**Location:** `spec/models/`, `spec/lib/`.

```ruby
# spec/models/premium_calculator_spec.rb
RSpec.describe PremiumCalculator do
  describe "#calculate" do
    it "calculates the correct premium" do
      calculator = PremiumCalculator.new(plan: plan, age: 30)
      expect(calculator.calculate).to eq(250.00)
    end
  end
end
```

**`spec/lib/`** is valid for tests of code in `lib/`. Note that `lib/` is a legacy directory
being gradually replaced by `app/models/`. New code should not go in `lib/`, and new tests
should follow the source.

**Legacy locations (do not add new files):**
- `spec/services/` — tests for classes in the `app/services/` junk-drawer. These migrate to `spec/models/` alongside source code migration.
- `spec/operations/` — 7 existing files for `app/operations/` classes. Migrate to `spec/models/` when those files are touched. New `app/operations/` specs go in `spec/models/`.

## Integration / Request Tests

**Purpose:** Test full HTTP request/response cycles.

**Location:** `spec/requests/`.

```ruby
# spec/requests/users_spec.rb
RSpec.describe "Users API" do
  describe "GET /users/:id" do
    let(:user) { create(:user) }

    it "returns the user" do
      get "/users/#{user.id}"

      expect(response).to have_http_status(:ok)
      expect(json_response[:name]).to eq(user.name)
    end
  end
end
```

## System Tests (browser simulation)

**Purpose:** Test user flows through the application with a real browser via Capybara.

**Location:** `spec/system/`.

```ruby
# spec/system/enrollment_spec.rb
RSpec.describe "Benefit Enrollment", type: :system do
  it "user enrolls in a benefit plan" do
    visit enrollment_path
    select "Health Plan A", from: "plan"
    click_button "Enroll"

    expect(page).to have_content("Successfully enrolled")
  end
end
```

**Legacy location (do not add new files):** `spec/ui/` — 84 existing browser specs migrating
to `spec/system/`. Files in `spec/system/` may temporarily use the Capybara `feature`/`scenario`
DSL until DSL conversion is complete.

## Job Specs

**Purpose:** Test ActiveJob classes in `app/jobs/`.

**Location:** `spec/jobs/`.

**Note:** The project's custom `Processor`-based background jobs (`lib/job_*.rb`) are NOT
ActiveJob and do NOT go in `spec/jobs/`. They belong in `spec/models/`.

## Helper, Mailer, and Routing Specs

| Layer | Location |
|-------|----------|
| View helpers (`app/helpers/`) | `spec/helpers/` |
| ActionMailer classes | `spec/mailers/` |
| Route definitions | `spec/routing/` |

## Controller Specs (Legacy)

**Status: Legacy.** Prefer `spec/requests/` for all new controller-related tests.

**Location:** `spec/controllers/`.

Existing `spec/controllers/` files are valid and will not be actively migrated as part of
the rspec cleanup plan. Do not add new controller specs — write request specs instead.

## View Templates (Project decision: do not test directly)

RSpec Rails supports `spec/views/` with `type: :view`, but **this project has made a
deliberate decision to ban view specs entirely**. Test rendering through:

- **Request specs** (`spec/requests/`) — verify response body content
- **System specs** (`spec/system/`) — for user-visible behavior requiring browser simulation

Do not create `spec/views/` specs.

## Related

- [`structure.md`](structure.md) — How to lay out `describe`/`context`/`it` regardless of test type.
- [`common_patterns.md`](common_patterns.md) — Templates per scenario (validations, API endpoints, jobs, etc.).
- [`../architecture/tests.md`](../architecture/tests.md) — Directory structure for spec files.
