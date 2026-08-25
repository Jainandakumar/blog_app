---
paths:
  - "app/models/**"
last_reviewed: 2026-05-19
---

# Query Objects

Query objects encapsulate complex database queries, returning ActiveRecord relations for chaining.

---

## Location

`app/models/[name]_query.rb` or `app/models/[namespace]/[name]_query.rb`

See `../architecture/code_placement.md` and `../architecture/models.md` for the full placement rules.

---

## Pattern

```ruby
class ExpiredPasswordsQuery
  def initialize(relation = User.all)
    @relation = relation
  end

  def call
    @relation
      .where("password_updated_at < ?", 90.days.ago)
      .where(password_expired_notified: false)
  end
end
```

**Usage:**

```ruby
# Basic usage
ExpiredPasswordsQuery.new.call

# Chain with other scopes
ExpiredPasswordsQuery.new(User.active).call.limit(100)
```

**Key characteristics:**
- Takes optional relation as input (defaults to `.all`)
- Returns ActiveRecord relation (chainable)
- Single query responsibility
- Keeps models clean of complex scopes

---

## When to Use

- Query logic is complex (multiple joins, subqueries)
- Same query needed in multiple places
- Query has business meaning worth naming

---

## Anti-patterns

**Query objects that return arrays** — Always return ActiveRecord relations so callers can chain. Use `.to_a` only at the call site if needed.

**Query objects that execute side effects** — Queries should only read data. If you need to update records, use a service object. See [service_objects.md](service_objects.md).

**Query objects with multiple query methods** — Each query object should do one thing. Create separate query objects for different queries.

**Repository pattern over ActiveRecord** — Don't recreate AR's job. See [anti_patterns.md](anti_patterns.md).

---

## Related

- [service_objects.md](service_objects.md) — for write/state-changing operations.
- [principles.md](principles.md) — the design principles query objects follow.
- `../style/business_logic.md` — implementation style for query objects.
