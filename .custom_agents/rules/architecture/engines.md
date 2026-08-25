---
paths:
  - "engines/**"
last_reviewed: 2026-05-19
---

# Engines

Rails engines, primarily the API engine.

---

## API Engine

Location: `engines/api/`

The API engine handles all RESTful API endpoints.

**Mounted at:** `/api`

---

## Structure

```
engines/api/
├── app/
│   ├── controllers/api/
│   │   ├── base_controller.rb
│   │   ├── v1/
│   │   │   └── users_controller.rb
│   │   └── internal/
│   │       └── v1/
│   └── serializers/
├── config/
│   └── routes.rb
├── docs/                    # OpenAPI/Swagger documentation
└── spec/
```

---

## API Versioning

URL-based versioning with namespaced controllers:

| Namespace | Purpose |
|-----------|---------|
| `Api::V1::` | Public API version 1 |
| `Api::V2::` | Public API version 2 |
| `Api::SelfService::V1::` | Self-service portal API |
| `Api::Internal::V1::` | Internal service API |

Example controller:
```ruby
# engines/api/app/controllers/api/v1/users_controller.rb
module Api
  module V1
    class UsersController < Api::BaseController
      def index
        @users = User.active
        render json: @users
      end
    end
  end
end
```

---

## API Documentation

OpenAPI/Swagger specs live in `engines/api/docs/`.

---

## Business Logic

**Business logic does NOT go in the API engine.**

API controllers should:
1. Authenticate/authorize
2. Parse parameters
3. Call models/services in `app/models/`
4. Serialize and return response

Complex operations belong in service objects in `app/models/`. See [`code_placement.md`](code_placement.md).
