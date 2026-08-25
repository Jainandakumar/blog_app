---
paths:
  - "lib/job_*.rb"
  - "lib/processor*.rb"
last_reviewed: 2026-05-19
---

# Security: background jobs

Security considerations specific to this project's `Processor` job system.

For the structural rules around the job system itself, see [../architecture/background_jobs.md](../architecture/background_jobs.md). For style and design rules, see [../style/background_job.md](../style/background_job.md) and [../design/background_job.md](../design/background_job.md).

---

## Multi-Tenancy

**Always scope queries to the job's entity.** Never query across tenants.

```ruby
# Good - scoped to entity
organization = self.job_request.entity
organization.subscribers.where(status: "active")

# Bad - unscoped
Subscriber.where(status: "active")
```

For the sharding model that backs this, see [../architecture/sharding.md](../architecture/sharding.md).

### Verify Cross-Tenant Access

```ruby
def validate_organization_access(organization_id)
  organization = Organization.find_by(id: organization_id)
  return false unless organization

  entity = self.job_request.entity
  case entity
  when MasterOrg
    organization.master_org_id == entity.id
  when Organization
    organization.id == entity.id
  else
    false
  end
end
```

---

## File Handling

**Use `StorageFile` model, never raw file paths from params.**

```ruby
# Good
storage_file = StorageFile.find_by(id: params[:storage_file_id])
storage_file.attachment.blob.open do |tempfile|
  process_file(tempfile)
end

# Bad - path traversal vulnerability
File.read(params[:file_path])
```

---

## Sensitive Data

### Filter Params in PsError

```ruby
def safe_params_for_error
  params = self.job_request.params.dup
  params.delete(:password)
  params.delete(:api_key)
  params.delete(:ssn)
  params
end
```

### Mask PII in Tickets

```ruby
safe_description = description.gsub(/\d{3}-\d{2}-\d{4}/, "XXX-XX-XXXX")
```

---

## External Credentials

Use `Crypto.encode()` for passwords:

```ruby
Transport.create!(
  ftp_password: Crypto.encode(ftp_account.password)
)
```

---

## Audit Context

Set at job start for tracking data modifications:

```ruby
User.current_process = "JobRequest: #{self.job_request.id} #{self.class.name}"
```

---

## Related

- [overview.md](overview.md) — Universal principles (least privilege, whitelist, never log secrets).
- [business_logic.md](business_logic.md) — Model-level SQL-injection / PII rules also apply inside jobs.
- [../architecture/background_jobs.md](../architecture/background_jobs.md) — `Processor` job structure and `JobRequest`/`PsError` glue.
- [../architecture/sharding.md](../architecture/sharding.md) — Multi-tenant sharding model that the scoping rules above protect.
- [../style/background_job.md](../style/background_job.md), [../design/background_job.md](../design/background_job.md) — Style and design rules for the same job system.
