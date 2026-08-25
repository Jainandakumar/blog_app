---
paths:
  - "spec/**"
last_reviewed: 2026-05-19
---

# Factories and fixtures

## Use FactoryBot for Test Data

**Location:** `spec/factories/`.

```ruby
# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    first_name { "John" }
    last_name { "Doe" }
    sequence(:email) { |n| "user#{n}@example.com" }
    status { "active" }

    trait :inactive do
      status { "inactive" }
    end

    factory :admin_user do
      role { "admin" }
    end
  end
end

# Usage
user = create(:user)
admin = create(:admin_user)
inactive_user = create(:user, :inactive)
users = create_list(:user, 3)
```

Application classes without a factory should have one added when you need test data for them. Authoring factories is preferred over inlining `Klass.new(...)` setup across many specs.

## Fixtures for Static Reference Data

**Location:** `spec/fixtures/` or `test/fixtures/`.

Use fixtures for static lookup tables, **not** for test objects.

```yaml
# spec/fixtures/states.yml
california:
  code: CA
  name: California

texas:
  code: TX
  name: Texas
```

## Related

- [`test_objects.md`](test_objects.md) — Why factories beat mocks for in-app objects (Detroit-school TDD).
- [`structure.md`](structure.md) — Pairing `let`/`let!` with `create`/`build` calls.
- [`../architecture/tests.md`](../architecture/tests.md) — Where `spec/factories/` sits in the repo.
