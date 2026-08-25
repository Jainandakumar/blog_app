---
paths:
  - "app/models/**"
last_reviewed: 2026-05-19
---

# Service Objects

Service objects encapsulate a single business operation or workflow.

---

## Location

`app/models/` or `app/models/[namespace]/`

**Legacy location:** `app/services/` (some existing code)

See `../architecture/code_placement.md` and `../architecture/models.md` for the full placement rules.

---

## Pattern

```ruby
class Users::Passwords::Creator
  def initialize(user, new_password)
    @user = user
    @new_password = new_password
  end

  def call
    # Business logic here
    # Returns result (object, boolean, or value)
  end
end
```

**Key characteristics:**
- Single responsibility (one operation)
- Takes inputs via constructor
- Performs logic in `call` method
- Returns meaningful result
- Keeps controllers thin and models focused on data

---

## Naming

Name describes the action: `Creator`, `Destroyer`, `Processor`, `Validator`, `Authenticator`.

Namespace by domain: `Users::Passwords::Creator`, `Enrollment::Processor`.

See also `../style/naming.md` and `../architecture/naming_conventions.md`.

---

## Anti-patterns

**Utility classes** — Classes that are just collections of unrelated methods. Each method should be its own service or belong to a domain object. See [anti_patterns.md](anti_patterns.md).

**God services** — Services that do too many things. Split into focused services.

**Services that just wrap ActiveRecord** — If you're just calling `Model.create`, you don't need a service.

---

## Related

- [query_objects.md](query_objects.md) — for read-only data fetching, not operations.
- [concerns.md](concerns.md) — for shared behavior across multiple classes.
- [principles.md](principles.md) — the design principles services follow.
- `../style/business_logic.md` — implementation style for service objects.
