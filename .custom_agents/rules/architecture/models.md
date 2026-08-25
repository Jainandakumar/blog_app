---
paths:
  - "app/models/**"
last_reviewed: 2026-05-19
---

# Models Directory

What belongs in `app/models/` and how it's organized.

---

## What Goes in app/models/

The `app/models/` directory contains ALL business logic:

| Type | Description | Example |
|------|-------------|---------|
| ActiveRecord models | Database-backed classes | `User`, `Enrollment`, `BenefitPlan` |
| Domain objects | POROs representing business concepts | `EligibilityResult` |
| Service objects | Encapsulated business operations | `Users::Authenticator` |
| Query objects | Complex database queries | `ActiveSubscribersQuery` |

---

## Directory Structure

```
app/models/
├── user.rb                    # ActiveRecord model
├── enrollment.rb              # ActiveRecord model
├── concerns/                  # Shared model behaviors
│   └── auditable.rb
└── users/                     # Namespace for User-related services
    ├── authenticator.rb       # Users::Authenticator
    └── password_checker.rb    # Users::PasswordChecker
```

---

## Naming and Namespacing

**Service objects** use namespace matching the primary model they operate on:

```ruby
# app/models/users/authenticator.rb
module Users
  class Authenticator
    def authenticate(email, password)
      # ...
    end
  end
end
```

**Concerns** go in `app/models/concerns/`:

```ruby
# app/models/concerns/auditable.rb
module Auditable
  extend ActiveSupport::Concern
  # ...
end
```

---

## Core Domain Models

Key entities in this application:

| Model | Purpose |
|-------|---------|
| Organization | Employers and groups |
| Subscriber | Employees (benefit recipients) |
| BenefitPlan | Insurance plans and options |
| Enrollment | Subscriber elections |
| Carrier | Insurance carriers |
| Policy | Carrier policy details |

---

## Custom Validators

Custom validation classes go in `app/validators/`:

```ruby
# app/validators/email_format_validator.rb
class EmailFormatValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    # ...
  end
end
```
