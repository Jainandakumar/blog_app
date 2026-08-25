---
paths:
  - "app/controllers/**"
last_reviewed: 2026-05-19
---

# Style: Controllers

General controller style. For API-specific concerns (JSON formats, status codes, versioning, API error envelopes) see [`api.md`](api.md).

---

## Controller Guidelines

### Keep Controllers Thin

Controllers should:
- Authenticate/authorize the request
- Parse parameters
- Call a model or service
- Render response

```ruby
# Good - thin controller
class UsersController < ApplicationController
  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to @user
    else
      render :new
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email)
  end
end

# Bad - business logic in controller
class UsersController < ApplicationController
  def create
    @user = User.new
    @user.name = params[:user][:name]
    @user.email = params[:user][:email].downcase.strip
    @user.status = "pending"
    @user.created_by = current_user.id
    @user.activation_token = SecureRandom.hex(32)

    if @user.valid?
      @user.save
      UserMailer.welcome(@user).deliver_later
      AuditLog.create(action: "user_created", user: @user)
      redirect_to @user
    else
      flash[:error] = "Validation failed"
      render :new
    end
  end
end
```

### Strong Parameters

Always use strong parameters. Never use `permit!`.

```ruby
# Good - explicit whitelist
def user_params
  params.require(:user).permit(:name, :email, :phone)
end

# Bad - permits everything
def user_params
  params.require(:user).permit!
end

# Sensitive attributes should NEVER be permitted
# role, admin, permissions, password_digest, etc.
```

### Before Actions

Use before_action for authentication and loading resources:

```ruby
class DocumentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_document, only: [:show, :edit, :update, :destroy]
  before_action :authorize_document, only: [:edit, :update, :destroy]

  private

  def set_document
    @document = Document.find(params[:id])
  end

  def authorize_document
    redirect_to root_path unless @document.editable_by?(current_user)
  end
end
```

---

## State-Changing Operations

### Use Appropriate HTTP Methods

```ruby
# Good - state changes via POST/PUT/DELETE
resources :users do
  member do
    post :activate
    delete :deactivate
  end
end

# Bad - state change via GET
get "users/:id/activate"  # NEVER do this
```

---

## Error Handling

### Rescue Common Errors

```ruby
class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActionController::ParameterMissing, with: :bad_request

  private

  def not_found
    render json: { error: "Not found" }, status: :not_found
  end

  def bad_request(exception)
    render json: { error: exception.message }, status: :bad_request
  end
end
```

---

## Related

- [`api.md`](api.md) — API-specific style (JSON envelopes, status codes, versioning).
- [`../architecture/controllers.md`](../architecture/controllers.md) — where controllers live and the request flow.
- [`../security/api.md`](../security/api.md) — CSRF, auth, mass-assignment hardening.
