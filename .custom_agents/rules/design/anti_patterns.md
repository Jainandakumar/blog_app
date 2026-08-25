---
paths:
  - "**/*.rb"
last_reviewed: 2026-05-19
---

# Design Anti-Patterns

Patterns we explicitly forbid. These derive from the principles in [principles.md](principles.md) and [solid.md](solid.md).

---

## FORBIDDEN: Utility Classes with Class Methods

**DO NOT create classes that only have class methods and no instance state.**

```ruby
# FORBIDDEN
class StringHelpers
  def self.titleize(str)
    str.split.map(&:capitalize).join(' ')
  end
end
```

**Why forbidden:**
- Not object-oriented (just functions in a namespace)
- Can't be composed with other objects (no state, no polymorphism)
- Can't be substituted in tests (class methods are globally referenced, not passed as collaborators)
- Usually means you haven't identified the real domain object

**Better alternatives:**
1. **Use Rails built-ins first:** `"hello".titleize` already exists
2. **Add behavior to domain objects:** If it operates on Users, put it on User
3. **Check if a gem provides it:** Search RubyGems before reinventing

---

## FORBIDDEN: Data Adapter / Repository Pattern Over ActiveRecord

**DO NOT create abstraction layers that Rails already provides.**

```ruby
# FORBIDDEN - recreating ActiveRecord's job
class UserRepository
  def find(id)
    # Manual SQL or ActiveRecord wrapping
  end

  def save(user)
    # Manual persistence logic
  end
end
```

**Why forbidden:**
- Rails/ActiveRecord IS your data abstraction layer
- You never write SQL directly but can access all data
- Adding another layer adds complexity without value
- Makes code harder to maintain and understand

If a user proposes this pattern, frame the pushback per `./rules/communication.md` § "Rails abstractions".

---

## FORBIDDEN: Passing Class Names + IDs Instead of Objects

**DO NOT pass class names and IDs when you can pass objects.**

```ruby
# FORBIDDEN (except background jobs - see exception below)
def process(model_class_name, record_id)
  klass = model_class_name.constantize
  record = klass.find(record_id)
  # ...
end
```

**Why forbidden:**
- Bypasses type safety
- Makes dependencies invisible
- Harder to test and debug
- Creates coupling to string constants

**EXCEPTION: Background jobs** can pass IDs (not class names) due to serialization:

```ruby
# Acceptable for background jobs only
class WelcomeEmailJob
  def perform(user_id)
    user = User.find(user_id)
    UserMailer.welcome(user).deliver_now
  end
end
```

See [background_job.md](background_job.md) for the full background-job design contract.

**Correct pattern for all other code:**

```ruby
# Good - pass objects
def process(enrollment)
  enrollment.activate!
end
```

---

## Related

- [principles.md](principles.md) — the principles these anti-patterns violate.
- [solid.md](solid.md) — SOLID context for why utility classes and repository-over-AR violate good design.
- [service_objects.md](service_objects.md) — the right way to extract a business operation (instead of a utility class).
- [query_objects.md](query_objects.md) — the right way to encapsulate a query (instead of a repository).
