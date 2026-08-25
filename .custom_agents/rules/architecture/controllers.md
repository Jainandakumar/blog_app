---
paths:
  - "app/controllers/**"
last_reviewed: 2026-05-19
---

# Controllers

Controller organization and structure.

---

## Web Controllers

Location: `app/controllers/`

Controllers are organized by module prefixes based on user type or feature area:

| Module | Purpose |
|--------|---------|
| `aa/` | Account admin |
| `admin/` | System administration |
| `ben/` |  administration |
| `org/` | Organization management |
| `sub/` | Subscriber portal |

Example:
```
app/controllers/
├── application_controller.rb
├── admin/
│   └── users_controller.rb      # Admin::UsersController
├── sub/
│   └── enrollments_controller.rb # Sub::EnrollmentsController
```

---

## API Controllers

Location: `engines/api/app/controllers/`

API endpoints use version namespacing:

```
engines/api/app/controllers/api/
├── base_controller.rb
├── v1/
│   └── users_controller.rb      # Api::V1::UsersController
└── v2/
    └── users_controller.rb      # Api::V2::UsersController
```

The API engine is mounted at `/api`.

---

## Controller Concerns

Shared controller behaviors go in `app/controllers/concerns/`:

```ruby
# app/controllers/concerns/authenticatable.rb
module Authenticatable
  extend ActiveSupport::Concern
  # ...
end
```

---

## Request Handling Flow

```
Request → Routes → Controller → Model/Service → View/JSON
```

Controllers should:
1. Authenticate/authorize the request
2. Parse parameters (strong params)
3. Call a model or service
4. Render response

Business logic belongs in models/services, NOT in controllers. See [`code_placement.md`](code_placement.md) and [`models.md`](models.md).
