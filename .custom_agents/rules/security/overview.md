---
paths:
  - "**/*.rb"
last_reviewed: 2026-05-19
---

# Security overview

Universal security principles. All code-writing agents read this file alongside the layer-specific rule for the code they are touching.

---

## Security Checklist

Before committing code, verify:

### Input Handling
- [ ] All user input is validated
- [ ] Strong parameters used (never `permit!`)
- [ ] File uploads are type/size restricted

### Data Protection
- [ ] No secrets or credentials in code
- [ ] Sensitive data is encrypted
- [ ] Sensitive data is not logged

### Access Control
- [ ] Authentication required for protected routes
- [ ] Authorization checks present
- [ ] Resources scoped to current user where appropriate

---

## Core Principles

### Never Trust User Input

All input from users, APIs, or external systems must be validated.

```ruby
# Always validate
validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
validates :status, inclusion: { in: VALID_STATUSES }
```

### Whitelist, Don't Blacklist

Define what's allowed, not what's forbidden.

```ruby
# Good - whitelist
ALLOWED_SORTS = %w[name created_at].freeze
sort = ALLOWED_SORTS.include?(params[:sort]) ? params[:sort] : "name"

# Bad - blacklist
sort = params[:sort] unless params[:sort] == "drop_table"
```

### Defense in Depth

Multiple security layers. Don't rely on a single check.

1. Client-side validation (UX, not security)
2. Controller-level authorization
3. Model-level validation
4. Database constraints

### Least Privilege

Grant minimum permissions needed.

```ruby
# Scope queries to what user can access
current_user.documents.find(params[:id])

# Not: Document.find(params[:id])
```

---

## Never Commit Secrets

Credentials, API keys, and secrets must come from environment:

```ruby
# Good
api_key = ENV["PAYMENT_GATEWAY_KEY"]
api_key = Rails.application.credentials.payment_key

# Bad - NEVER do this
api_key = "sk_live_abc123"
```

Secrets must come from `ENV` or Rails credentials. Never hardcode them in source files.

---

## Logging Security

### Never Log

- Passwords
- Credit card numbers
- SSNs or government IDs
- API keys or tokens
- Session IDs
- Full request bodies with PII

### Configure Filtering

```ruby
# config/initializers/filter_parameter_logging.rb
Rails.application.config.filter_parameters += [
  :password, :ssn, :credit_card, :token
]
```

---

## Security Testing

Before production:

```bash
# Check for vulnerable gems
bundle audit

# Static security analysis
brakeman
```

See [../testing/](../testing/) for project-wide testing rules; see [../workflows/](../workflows/) for hotpatch workflows.

---

## Related

- [business_logic.md](business_logic.md) — SQL injection, PII, input validation, encryption.
- [api.md](api.md) — Controller-layer security (CSRF, mass assignment, IDOR, auth).
- [http.md](http.md) — HTTP-edge security (JSON responses, redirects, rate limiting, headers).
- [ui.md](ui.md) — XSS, output encoding, view-level authorization.
- [background_job.md](background_job.md) — `Processor` job security.
