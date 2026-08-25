---
paths:
  - "lib/job_*.rb"
  - "lib/processor*.rb"
last_reviewed: 2026-05-19
---

# Background Jobs

Custom background job system using the `Processor` base class.

---

## Important

**This is NOT Sidekiq and NOT ActiveJob.**

This application uses a custom-built internal queueing system. Job classes inherit from `Processor` and live in `lib/`.

> **Legacy Pattern Note:** This is the default pattern for this codebase. Only ActiveJob classes (not yet in use) should go in `app/jobs/`. Agents have special permission to create new files in `lib/` for job classes — this is the documented exception to the [`lib.md`](lib.md) rule.

---

## System Overview

- Jobs inherit from `Processor` (`lib/processor.rb`)
- Jobs are persisted via `JobRequest` records in the database
- Each job type has a unique `lookup_code` matching `job_request_types.lookup_code`
- Progress tracked via `@progress_logger`
- Errors recorded as `PsError` records

---

## File and Class Naming

| Element | Pattern | Example |
|---------|---------|---------|
| File | `lib/job_[name].rb` | `lib/job_data_export.rb` |
| Class | `Job[Name] < Processor` | `JobDataExport` |
| Lookup code | snake_case, matches file | `"data_export"` |

---

## Required Structure

```ruby
class JobExampleTask < Processor
  def self.lookup_code
    "example_task"  # Must match job_request_types.lookup_code in DB
  end

  def process_job
    # Main entry point - called by worker
  end
end
```

---

## Accessing Job Data

Jobs access data through `self.job_request`:

| Accessor | Type | Description |
|----------|------|-------------|
| `.id` | Integer | Job request ID |
| `.entity` | ActiveRecord | Owner (`Organization` or `MasterOrg`) |
| `.params` | Hash | Parameters (symbol keys, primitive values only — IDs, not objects) |

---

## Key Patterns

**Progress tracking:**
```ruby
@progress_logger.init_phase(100)
@progress_logger.next_phase(50)
@progress_logger.finalize_phase
```

**Error recording:** Create `PsError` with fields: `exception`, `message`, `process`, `changed_by`

**Tickets:** Use `Ticket` model with `ticket_type` (via `lookup_code`), `master_org`, `organization`, `source` (`job_request`), `application_code`

**Business logic:** Delegate to services in `app/models/`, don't embed in the job class.

---

## Related Rules

- **Design:** [`./rules/design/background_job.md`](../design/background_job.md)
- **Style:** [`./rules/style/background_job.md`](../style/background_job.md)
- **Security:** [`./rules/security/background_job.md`](../security/background_job.md)
