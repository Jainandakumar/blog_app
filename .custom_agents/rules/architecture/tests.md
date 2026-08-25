---
paths:
  - "spec/**"
  - "test/**"
last_reviewed: 2026-06-30
---

# Test Structure

Test directories and frameworks. This file covers **where tests live**; behavioral testing rules (what to test, how to structure specs, factories, etc.) live in [`./rules/testing/`](../testing/).

---

## Primary Framework: RSpec

**Location:** `spec/`

```
spec/
├── models/        # Models, service objects, query objects, Processor jobs (lib/job_*.rb)
├── controllers/   # LEGACY — controller specs; prefer spec/requests/ for new tests
├── requests/      # HTTP request/response integration tests
├── system/        # Browser tests (Capybara); canonical location for all new browser specs
├── helpers/       # View helper specs (app/helpers/)
├── mailers/       # ActionMailer specs
├── jobs/          # ActiveJob specs (app/jobs/ only — NOT Processor jobs)
├── routing/       # Route specs
├── lib/           # Tests for lib/ code (valid but legacy; follows the lib/ source)
├── support/       # Shared helpers, contexts, shared examples
└── factories/     # FactoryBot factory definitions

Legacy locations (do not add new files here):
├── spec/services/ # Migrating to spec/models/ as app/services/ source code is relocated
└── spec/ui/       # Migrating to spec/system/
```

**Configuration:** `spec/spec_helper.rb`

**`spec_helper.rb` vs `rails_helper.rb`:** This project's `spec/spec_helper.rb` loads the
full Rails environment (`config/environment`, `rspec/rails`, `factory_bot_rails`). There is
no separate `rails_helper.rb`. Use `require 'spec_helper'` in all spec files — **except**
system specs (`spec/system/`), which use `require 'capybara_helper'` instead. `capybara_helper`
loads Capybara, Selenium, and screenshot support, then calls `spec_helper` internally. This is
equivalent to `rails_helper` in a standard Rails project — the naming is project-specific.

---

## Legacy Framework: Minitest

**Location:** `test/`

```
test/
├── unit/
├── functional/
└── integration/
```

**Status:** Being phased out. Do not add new `Test::Unit` tests.

When touching legacy tests, convert to RSpec when practical.

---

## Running Tests

**RSpec (primary):**
```bash
# Single file (recommended for local development)
bundle exec rspec spec/models/user_spec.rb

# Single test by line number
bundle exec rspec spec/models/user_spec.rb:42

# Directory
bundle exec rspec spec/models/
```

**Minitest (legacy):**
```bash
bundle exec rake --rakefile Rakefile.norails ci:unit
```

---

## Test Data

**FactoryBot factories:** `spec/factories/`

```ruby
# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    first_name { "John" }
    sequence(:email) { |n| "user#{n}@example.com" }
  end
end
```

**Fixtures:** `spec/fixtures/` or `test/fixtures/`
- Use for static lookup tables
- Not for test objects (use factories)

---

## CI/CD

Full test suite runs in GitHub CI. Takes significant time.

Developers should run targeted tests locally using `rspec-changed` script or specific paths.

See [`./rules/testing/`](../testing/) for complete testing guidelines.
