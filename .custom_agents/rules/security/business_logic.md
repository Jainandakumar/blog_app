---
paths:
  - "app/models/**"
  - "lib/**/*.rb"
last_reviewed: 2026-05-19
---

# Security: business logic

Security guidelines for models, services, and data handling.

---

## SQL Injection Prevention

Never interpolate user input into SQL queries.

```ruby
# VULNERABLE - string interpolation
User.where("email = '#{params[:email]}'")
User.where("status = #{params[:status]}")

# SECURE - parameterized queries
User.where("email = ?", params[:email])
User.where(email: params[:email])
User.where("email = :email", email: params[:email])
```

### Safe ActiveRecord Methods

These methods safely escape input:
- `where(column: value)` - Hash conditions
- `where("column = ?", value)` - Placeholders
- `find_by(column: value)`
- `find(id)`

### Unsafe Patterns to Avoid

```ruby
# Bad - raw SQL with interpolation
connection.execute("SELECT * FROM users WHERE id = #{id}")

# Bad - order/group with user input
User.order(params[:sort])  # Can inject SQL!

# Safe - whitelist allowed values
ALLOWED_SORTS = %w[name created_at email].freeze
sort_column = ALLOWED_SORTS.include?(params[:sort]) ? params[:sort] : "name"
User.order(sort_column)
```

---

## Data Protection

### Personally Identifiable Information (PII)

PII includes: names, addresses, email, SSN, DOB, financial data, health info.

**Requirements:**
- Encrypt PII at rest (use Rails encrypted attributes)
- Encrypt in transit (HTTPS)
- Minimize collection (only what's needed)
- Log access to sensitive data

```ruby
class User < ApplicationRecord
  encrypts :ssn
  encrypts :bank_account
end
```

### Never Log Sensitive Data

```ruby
# config/initializers/filter_parameter_logging.rb
Rails.application.config.filter_parameters += [
  :password,
  :ssn,
  :credit_card,
  :bank_account,
  :api_key,
  :token
]
```

---

## Input Validation

### Validate All User Input

```ruby
class User < ApplicationRecord
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :age, numericality: { greater_than: 0, less_than: 150 }, allow_nil: true
  validates :role, inclusion: { in: %w[user admin] }
  validates :ssn, format: { with: /\A\d{3}-\d{2}-\d{4}\z/ }, allow_blank: true
end
```

### Whitelist, Don't Blacklist

```ruby
# Good - whitelist allowed values
VALID_STATUSES = %w[pending active suspended].freeze
validates :status, inclusion: { in: VALID_STATUSES }

# Bad - trying to block bad values
validates :status, exclusion: { in: ["hacked", "evil"] }
```

---

## File Upload Validation

Use `active_storage_validations` gem to validate file types and sizes:

```ruby
class Document < ApplicationRecord
  has_one_attached :file

  validates :file, attached: true, size: { less_than: 10.megabytes },
                   content_type: ["application/pdf", "image/png", "image/jpeg"]
end

class User < ApplicationRecord
  has_many_attached :files

  validates :files, limit: { max: -> (record) { record.admin? ? 100 : 10 } }
end
```

---

## Command Injection Prevention

Avoid system commands with user input entirely.

```ruby
# VULNERABLE
system("ls #{params[:directory]}")
`cat #{file_path}`

# SAFER - array form
system("ls", "-la", sanitized_directory)

# BEST - use Ruby libraries
Dir.entries(sanitized_directory)
File.read(sanitized_path)
```

---

## Encryption

### Use Rails Encrypted Attributes

```ruby
class Secret < ApplicationRecord
  encrypts :api_key
  encrypts :private_data, deterministic: true  # For querying
end
```

### Environment Variables for Secrets

```ruby
# Good - from environment
api_key = ENV["PAYMENT_GATEWAY_KEY"]

# Good - Rails credentials
api_key = Rails.application.credentials.payment_gateway_key

# Bad - hardcoded
api_key = "sk_live_abc123"  # NEVER do this
```

---

## Secure Deletion

When deleting PII:
- Use hard delete, not soft delete for truly sensitive data
- Purge from backups if required by policy
- Log the deletion for audit purposes

```ruby
# Secure deletion
user.destroy  # Removes record
user.audit_logs.destroy_all  # Remove associated sensitive data

# Soft delete is NOT secure for PII
user.update(deleted_at: Time.current)  # Data still exists!
```

## Related

- Within security: [overview.md](overview.md), [api.md](api.md), [background_job.md](background_job.md).
- Architecture: [../architecture/models.md](../architecture/models.md), [../architecture/sharding.md](../architecture/sharding.md).
- Style and design: [../style/business_logic.md](../style/business_logic.md), [../design/service_objects.md](../design/service_objects.md), [../design/query_objects.md](../design/query_objects.md).
