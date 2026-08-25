---
paths:
  - "lib/job_*.rb"
  - "lib/processor*.rb"
last_reviewed: 2026-05-19
---

# Style: Background Jobs

Implementation patterns for the custom `Processor` job system. For the architectural rules (file location, class naming, system overview) see [`../architecture/background_jobs.md`](../architecture/background_jobs.md).

> For existing examples, see `lib/job_*.rb` files in the codebase.

---

## Class Structure

```ruby
class JobExampleTask < Processor
  include SomeModule  # Optional mixins

  BATCH_SIZE = 1000   # Optional constants

  def self.lookup_code
    "example_task"
  end

  def initialize
    super
    @processname = self.class.name
  end

  def process_job
    @progress_logger.init_phase(100)

    # Validate, then delegate to service
    return unless validate_params

    organization = Organization.find_by(id: params[:organization_id])
    SomeService.new(organization).perform

    @progress_logger.finalize_phase
  rescue => e
    handle_error(e)
    raise e
  end

  private

  def params
    self.job_request.params
  end

  def validate_params
    # Return false and create ticket if invalid
  end

  def handle_error(exception)
    # Create PsError record
  end
end
```

---

## Project-Specific Patterns

### PsError Creation

```ruby
error = PsError.new
error.exception = exception
error.message = exception.message
error.process = self.class.name
error.changed_by = self.class.name
error.save
```

### Ticket Creation

```ruby
ticket = Ticket.new
ticket.summary = "#{self.class.name} Failed"
ticket.description = description
ticket.ticket_type = TicketType.find_by(lookup_code: "your_ticket_type")
ticket.master_org = determine_master_org
ticket.organization = @organization
ticket.source = self.job_request
ticket.application_code = ""
ticket.save!
```

### Determine Owner (MasterOrg vs Organization)

```ruby
def determine_master_org
  entity = self.job_request.entity
  entity.is_a?(MasterOrg) ? entity : entity.broker_master_org
end
```

### Audit Context

Set audit context at start of job:

```ruby
User.current_process = "JobRequest: #{self.job_request.id} #{self.class.name}"
```

---

## Business Logic

**Always delegate to services in `app/models/`** — jobs are orchestration only.

```ruby
# Good
Organizations::DataExporter.new(organization).export

# Bad - business logic in job
# 50 lines of export logic here...
```

---

## Related

- [`../architecture/background_jobs.md`](../architecture/background_jobs.md) — file location, class naming, system overview.
- [`../design/background_job.md`](../design/background_job.md) — design patterns for `Processor` jobs.
- [`../security/background_job.md`](../security/background_job.md) — `Processor` job security.
- [`active_record_caching.md`](active_record_caching.md) — the AR-caching exception for jobs (pass IDs, not objects).
