---
paths:
  - "**/*.rb"
last_reviewed: 2026-05-19
---

# Core Design Principles

Three foundational principles that shape every design decision. Applied alongside [solid.md](solid.md) and [anti_patterns.md](anti_patterns.md).

---

## 1. Clarity Over Cleverness

Write code that is easy to understand and maintain, not code that shows off language features or clever tricks.

```ruby
# Good - clear and explicit
def active_users
  users.where(status: "active")
end

# Bad - too clever
def active_users
  users.select(&:active?)
end
```

---

## 2. Composition Over Inheritance

Prefer composition (using objects together) over deep inheritance hierarchies.

```ruby
# Good - composition
class ReportGenerator
  def initialize(data_source, formatter)
    @data_source = data_source
    @formatter = formatter
  end

  def generate
    data = @data_source.fetch
    @formatter.format(data)
  end
end

# Bad - deep inheritance
class Report
end

class UserReport < Report
end

class AdminUserReport < UserReport
end

class SuperAdminUserReport < AdminUserReport
end
```

---

## 3. Explicit Over Implicit

Make dependencies and behaviors explicit rather than relying on hidden coupling or magic.

```ruby
# Good - explicit dependencies
class OrderProcessor
  def initialize(order, payment_gateway, notifier)
    @order = order
    @payment_gateway = payment_gateway
    @notifier = notifier
  end

  def process
    @payment_gateway.charge(@order.total)
    @notifier.send_confirmation(@order.user)
  end
end

# Bad - implicit dependencies
class OrderProcessor
  def process(order)
    PaymentGateway.charge(order.total)  # Hidden dependency
    Notifier.send(order.user)  # Hidden dependency
  end
end
```

---

## Related

- [solid.md](solid.md) — SOLID principles and the SRP misconception.
- [anti_patterns.md](anti_patterns.md) — patterns these principles rule out.
- [refactoring.md](refactoring.md) — applying these principles to existing code.
