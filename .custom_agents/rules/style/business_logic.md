---
paths:
  - "app/models/**"
last_reviewed: 2026-05-19
---

# Style: Business Logic

Guidelines for models, services, and business logic code in `app/models/`.

---

## ActiveRecord Patterns

### Use Scopes for Reusable Queries

```ruby
# Good
class User < ApplicationRecord
  scope :active, -> { where(status: "active") }
  scope :admins, -> { where(role: "admin") }
end

User.active.admins

# Bad - repeated conditions
User.where(status: "active").where(role: "admin")
```

### Prefer find_by Over where().first

```ruby
# Good
User.find_by(email: email)

# Bad
User.where(email: email).first
```

### Use find_each for Large Result Sets

```ruby
# Good - batches of 1000
User.find_each do |user|
  process_user(user)
end

# Bad - loads all into memory
User.all.each do |user|
  process_user(user)
end
```

### Keep Models Focused

Models should handle:
- Validations
- Associations
- Scopes
- Simple business logic

Extract complex logic to service objects or domain objects in `app/models/[namespace]/`.

When implementation becomes too complex or exceeds recommended size limits, Architecture and Design Agents can review the plan with the new code context (use `NEEDS_DECISION` to escalate).

---

## Callbacks

### Avoid Complex Callbacks

```ruby
# Bad - side effects in callbacks
class User < ApplicationRecord
  after_create :send_welcome_email
  after_create :create_default_settings
  after_create :notify_admins
  after_create :log_creation
end

# Better - explicit in service
class Users::Creator
  def create(params)
    user = User.create!(params)
    UserMailer.welcome(user).deliver_later
    user.create_default_settings!
    # ...
  end
end
```

### Acceptable Callbacks

- `before_validation` for data normalization
- `before_save` for computed fields
- Simple, single-purpose callbacks

---

## Validations

### Validate at Model Level

```ruby
class User < ApplicationRecord
  validates :email, presence: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP },
                    uniqueness: { case_sensitive: false }
  validates :age, numericality: { greater_than: 0, less_than: 150 },
                  allow_nil: true
end
```

### Custom Validation Methods

```ruby
class Enrollment < ApplicationRecord
  validate :start_date_before_end_date

  private

  def start_date_before_end_date
    return unless start_date && end_date
    return if start_date < end_date

    errors.add(:end_date, "must be after start date")
  end
end
```

---

## Associations

### Always Specify dependent Option

```ruby
class User < ApplicationRecord
  has_many :documents, dependent: :destroy
  has_many :audit_logs, dependent: :nullify
  has_one :profile, dependent: :destroy
end
```

### Use Inverse Of for Bi-directional Associations

```ruby
class Author < ApplicationRecord
  has_many :books, inverse_of: :author
end

class Book < ApplicationRecord
  belongs_to :author, inverse_of: :books
end
```

---

## Related

- [`../architecture/models.md`](../architecture/models.md) — where models live and how `app/models/` is organized.
- [`../design/service_objects.md`](../design/service_objects.md) — service object pattern for extracting complex logic.
- [`../design/query_objects.md`](../design/query_objects.md) — query object pattern.
- [`active_record_caching.md`](active_record_caching.md) — pass objects, not IDs.
