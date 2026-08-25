---
universal: true
last_reviewed: 2026-05-19
---

# Code Placement

Where to put new code in the codebase.

---

## Default Location

**Business logic defaults to `app/models/`** unless Rails conventions direct you elsewhere.

This includes:
- ActiveRecord models (database-backed)
- Service objects
- Domain objects (POROs)
- Query objects
- Business logic classes

**NOT in:**
- `lib/` - Legacy dumping ground with bi-directional dependencies
- `engines/` or `components/` - UI isolation only, not business logic

---

## Decision Tree

**Is it a model backed by a database table?**
→ `app/models/[name].rb`

**Is it a service object / business logic class?**
→ `app/models/[name].rb` or `app/models/[namespace]/[name].rb`

**Is it a controller handling HTTP requests?**
→ `app/controllers/[module]/[name]_controller.rb`

**Is it a custom validator?**
→ `app/validators/[name]_validator.rb`

**Is it a utility function?**
→ **FIRST:** Check if Rails provides it (`String#titleize`, `Array#pluck`, etc.)
→ **SECOND:** Check if a gem provides it
→ **LAST RESORT:** `app/models/` with clear namespace

**Is it an integration with an external system?**
→ Edit existing code in `lib/integrations/[system_name]/` if it exists
→ Otherwise: `app/models/integrations/[name].rb`

**Is it part of engines/components?**
→ **UI code (views/controllers/presenters):** OK in engines
→ **Business logic:** NO — put in `app/models/`
→ **Editing existing code:** OK
→ **New business classes:** NO

**Is it an API endpoint?**
→ `engines/api/app/controllers/api/[namespace]/[version]/[name]_controller.rb`

**Is it a background job class (`Job*` inheriting from `Processor`)?**
→ `lib/job_[name].rb` — the documented exception for the custom job system. See [`background_jobs.md`](background_jobs.md).

---

## Why This Matters

- `app/models/` is autoloaded and tested consistently
- `lib/` has dependency issues and inconsistent loading
- `engines/` and `components/` are for UI isolation, not business logic
