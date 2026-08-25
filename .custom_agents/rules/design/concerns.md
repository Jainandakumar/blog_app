---
paths:
  - "app/models/concerns/**"
  - "app/controllers/concerns/**"
last_reviewed: 2026-05-19
---

# Concerns

Concerns extract shared behavior for inclusion in multiple classes.

---

## Location

- Model concerns: `app/models/concerns/`
- Controller concerns: `app/controllers/concerns/`

See `../architecture/code_placement.md` for the full placement rules.

---

## Pattern

```ruby
module Archivable
  extend ActiveSupport::Concern

  included do
    scope :archived, -> { where.not(archived_at: nil) }
    scope :active, -> { where(archived_at: nil) }
  end

  def archive!
    update(archived_at: Time.current)
  end

  def archived?
    archived_at.present?
  end
end
```

**Usage:**

```ruby
class BenefitPlan < ApplicationRecord
  include Archivable
end
```

---

## When to Use

- Identical behavior needed in 3+ unrelated classes
- Behavior is cohesive (all methods relate to one concept)
- Mixed into classes via `include`

---

## Anti-patterns

**Kitchen sink concerns** — Concerns that include unrelated methods. Each concern should have a single, clear purpose.

**Concerns for code organization** — Don't use concerns just to make a model file shorter. If methods belong together logically, they should stay in the model.

**Concerns used by only one class** — If only one class uses it, the code should be in that class.

**Deep concern chains** — Concerns that include other concerns. Keep the hierarchy flat.

---

## Related

- [service_objects.md](service_objects.md) — for extracting business operations rather than shared behavior.
- [principles.md](principles.md) — composition over inheritance; concerns are a Ruby-specific composition tool.
- `../architecture/models.md` — model directory structure (including `concerns/`).
