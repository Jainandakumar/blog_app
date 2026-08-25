---
paths:
  - "app/controllers/**"
  - "engines/api/**"
last_reviewed: 2026-05-19
---

# Security: HTTP edge

HTTP-edge concerns that sit just outside the controller: response payload safety, redirects, rate limiting, security headers.

For controller-level rules (CSRF, mass assignment, IDOR, auth) see [api.md](api.md).

---

## JSON Response Security

### Don't Expose Sensitive Data in API Responses

```ruby
# Bad - exposes everything
render json: @user

# Good - explicit serialization
render json: {
  id: @user.id,
  name: @user.name,
  email: @user.email
  # No password_digest, ssn, etc.
}

# Better - use serializers
render json: UserSerializer.new(@user)
```

### Proper JSON Content Type

```ruby
render json: data, content_type: "application/json"
```

For JSON-envelope/version conventions (status codes, success/error envelopes) see [../style/api.md](../style/api.md).

---

## Open Redirect Prevention

Validate redirect URLs to prevent phishing attacks:

```ruby
# VULNERABLE - open redirect
redirect_to params[:return_to]

# SAFE - whitelist allowed paths
def safe_redirect(url)
  uri = URI.parse(url)
  if uri.host.nil? || uri.host == request.host
    redirect_to url
  else
    redirect_to root_path
  end
end
```

---

## Rate Limiting

Protect against brute force attacks:

```ruby
# In routes or controller
throttle("login", limit: 5, period: 1.minute) do |req|
  req.ip if req.path == "/login" && req.post?
end
```

---

## Security Headers

Ensure proper headers are set (usually in middleware):

- `X-Frame-Options: DENY` - Prevent clickjacking
- `X-Content-Type-Options: nosniff` - Prevent MIME sniffing
- `X-XSS-Protection: 1; mode=block` - XSS filter
- `Strict-Transport-Security` - Force HTTPS

---

## Related

- [api.md](api.md) — Controller-level CSRF / mass assignment / IDOR / auth rules.
- [ui.md](ui.md) — XSS prevention belongs in the view layer; this file is HTTP-edge only.
- [overview.md](overview.md) — Universal principles.
- [../style/api.md](../style/api.md) — JSON envelope conventions for API controllers.
