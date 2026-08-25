---
last_reviewed: 2026-05-19
---

# Style rules

Code style and formatting rules for Ruby, Rails, and ERB in the management platform. This folder splits style content into project-wide rules (apply to every Ruby file regardless of layer) and domain-specific rules (apply only when working in that layer). Out of scope: where code goes ([`./rules/architecture/`](../architecture/)), design patterns ([`./rules/design/`](../design/)), security ([`./rules/security/`](../security/)), testing rules ([`./rules/testing/`](../testing/)).

## Subtopic index

### Project-wide style (apply everywhere)

| File | Topic |
|---|---|
| [`essentials.md`](essentials.md) | Essential rules at a glance: quotes, indentation, line length, whitespace, formatting. |
| [`naming.md`](naming.md) | Classes, modules, methods, variables, constants, files. |
| [`ruby.md`](ruby.md) | Ruby idioms: strings, hashes, arrays, conditionals, methods, blocks. |
| [`active_record_caching.md`](active_record_caching.md) | Pass objects (not IDs) between methods to preserve ActiveRecord association caching. Background-job exception included. |
| [`replica_reads.md`](replica_reads.md) | When and how to use `Shards.using_replica_shard` for replica reads: safety rules, testing requirements, terminology. |
| [`linters.md`](linters.md) | RuboCop and Pronto commands. |

### Domain-specific style (apply only in that layer)

| File | Topic |
|---|---|
| [`business_logic.md`](business_logic.md) | Models, services, and `app/models/` code: scopes, callbacks, validations, associations. |
| [`controllers.md`](controllers.md) | General controller style: thin controllers, strong parameters, before-actions, error rescues. |
| [`api.md`](api.md) | API-specific style: JSON envelopes, HTTP status codes, versioning. |
| [`ui.md`](ui.md) | Views, ERB templates, and frontend conventions. |
| [`background_job.md`](background_job.md) | Implementation patterns for the custom `Processor` job system. See also [`../architecture/background_jobs.md`](../architecture/background_jobs.md). |
