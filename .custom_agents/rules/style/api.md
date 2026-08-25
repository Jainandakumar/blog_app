---
paths:
  - "engines/api/**"
last_reviewed: 2026-05-19
---

# Style: API endpoints

API-specific style: JSON envelopes, status codes, versioning. For general controller style (thin controllers, strong params, before-actions, error rescues) see [`controllers.md`](controllers.md).

---

## API Controllers

### JSON Response Format

**Single resource:**
```ruby
render json: @user
```

**Collection with pagination:**
```json
{
  "data": [ /* resources */ ],
  "meta": {
    "current_page": 2,
    "per_page": 25,
    "total_pages": 10,
    "total_count": 250
  },
  "links": {
    "self": "/api/v1/users?page=2",
    "first": "/api/v1/users?page=1",
    "prev": "/api/v1/users?page=1",
    "next": "/api/v1/users?page=3",
    "last": "/api/v1/users?page=10"
  }
}
```

**Error response format:**
```json
{
  "error": {
    "code": "validation_error",
    "message": "Validation failed",
    "details": {
      "email": ["is invalid"],
      "name": ["can't be blank"]
    }
  }
}
```

Standard error codes: `validation_error`, `unauthorized`, `forbidden`, `not_found`, `internal_error`

**Use serializers for complex objects:**
```ruby
render json: UserSerializer.new(@user)
```

### HTTP Status Codes

| Situation | Status Code |
|-----------|-------------|
| Success | 200 OK |
| Created | 201 Created |
| No content | 204 No Content |
| Bad request | 400 Bad Request |
| Unauthorized | 401 Unauthorized |
| Forbidden | 403 Forbidden |
| Not found | 404 Not Found |
| Unprocessable | 422 Unprocessable Entity |
| Server error | 500 Internal Server Error |

### API Versioning

API endpoints live in `engines/api/` with version namespacing:

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

## Related

- [`controllers.md`](controllers.md) — general controller style (thin controllers, strong params, before-actions, error rescues).
- [`../architecture/engines.md`](../architecture/engines.md) — the API engine at `engines/api/` and versioning.
- [`../security/api.md`](../security/api.md) — CSRF, auth, mass-assignment hardening.
