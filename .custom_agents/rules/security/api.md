---
paths:
  - "app/controllers/**"
  - "engines/api/**"
last_reviewed: 2026-05-19
---

# Security: controllers and request handling

Controller-layer security: CSRF, mass assignment, IDOR, authentication, authorization.

For HTTP-edge concerns (JSON response shape, open-redirect, rate limiting, security headers) see [http.md](http.md).

---

## Cross-Site Request Forgery (CSRF)

Rails includes CSRF protection by default. Never disable it.

```ruby
# VULNERABLE - skipping CSRF
class PaymentsController < ApplicationController
  skip_before_action :verify_authenticity_token  # NEVER do this
end

# SECURE - keep default protection
class PaymentsController < ApplicationController
  # authenticity token verified automatically
end
```

### State Changes Require POST/PUT/DELETE

```ruby
# VULNERABLE - state change via GET
get "users/:id/delete"  # Anyone can delete via link!

# SECURE - proper HTTP method
delete "users/:id", to: "users#destroy"
```

---

## Mass Assignment Protection

Always use strong parameters. Never permit all attributes.

```ruby
# VULNERABLE - permits everything
def user_params
  params.require(:user).permit!
end

# VULNERABLE - no strong params
@user = User.new(params[:user])

# SECURE - explicit whitelist
def user_params
  params.require(:user).permit(:name, :email, :phone)
  # role, admin, permissions are NOT permitted
end
```

`params.permit!` is also called out as a forbidden anti-pattern — see [../design/anti_patterns.md](../design/anti_patterns.md).

### Sensitive Attributes to NEVER Permit

- `role`, `admin`, `permissions`
- `password_digest`, `encrypted_password`
- `reset_token`, `activation_token`
- `created_at`, `updated_at`
- Foreign keys that shouldn't change

---

## Insecure Direct Object References (IDOR)

Always verify the user can access the requested resource.

```ruby
# VULNERABLE - no authorization
def show
  @document = Document.find(params[:id])
  # Any user can view any document!
end

# SECURE - scope to current user
def show
  @document = current_user.documents.find(params[:id])
end

# SECURE - explicit authorization
def show
  @document = Document.find(params[:id])
  authorize @document  # Raises if not allowed
end
```

---

## Authentication

### Require Authentication on Protected Routes

```ruby
class ApplicationController < ActionController::Base
  before_action :authenticate_user!
end

class PublicController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]
end
```

### Session Security

```ruby
# config/initializers/session_store.rb
Rails.application.config.session_store :cookie_store,
  key: "_app_session",
  secure: Rails.env.production?,  # HTTPS only in production
  httponly: true,                 # Not accessible via JavaScript
  same_site: :lax                 # CSRF protection
```

### Session Management

- Regenerate session ID after login
- Clear session on logout
- Implement session timeout

```ruby
def create_session(user)
  reset_session  # Prevent session fixation
  session[:user_id] = user.id
  session[:created_at] = Time.current
end

def destroy_session
  reset_session  # Clear everything
end
```

---

## Authorization

### Default to Deny

```ruby
# Good - whitelist what's allowed
class DocumentPolicy
  def show?
    user.admin? || record.user_id == user.id || record.public?
  end
end

# Bad - blacklist what's denied
class DocumentPolicy
  def show?
    !record.confidential? && !record.deleted?
    # Easy to miss cases!
  end
end
```

### Check Authorization at Multiple Levels

1. **Controller level** - Can user access this action?
2. **Query level** - Scope records to what user can see

```ruby
def index
  authorize Document                   # Controller level
  @documents = policy_scope(Document)  # Query level - only visible docs
end
```

---

## Related

- [http.md](http.md) — JSON response security, open-redirect, rate limiting, security headers.
- [overview.md](overview.md) — Universal principles (whitelist, defense in depth, least privilege).
- [business_logic.md](business_logic.md) — Model-level input validation that complements controller-level strong params.
- [../architecture/controllers.md](../architecture/controllers.md) — Controller organization.
- [../style/controllers.md](../style/controllers.md), [../style/api.md](../style/api.md) — Style for controllers.
- [../design/anti_patterns.md](../design/anti_patterns.md) — `params.permit!` listed as forbidden.
