---
last_reviewed: 2026-05-19
---

# Architecture rules

System architecture for the  management platform: a Ruby on Rails modular monolith with MySQL sharding, an internal custom background-job system (NOT Sidekiq, NOT ActiveJob), and Capistrano + Passenger deployment (NOT Docker). This folder is the canonical home for **where code goes** and **how the layers fit together**. Out of scope: design patterns ([`./rules/design/`](../design/)), code style ([`./rules/style/`](../style/)), testing rules ([`./rules/testing/`](../testing/)), security ([`./rules/security/`](../security/)).

## Subtopic index

| File | Topic |
|---|---|
| [`system_overview.md`](system_overview.md) | Big-picture map: what the platform does, layered architecture, multi-tenancy, security model. |
| [`code_placement.md`](code_placement.md) | Where new code goes (default `app/models/`); decision tree for new files. Universal rule — loads every session. |
| [`models.md`](models.md) | What belongs in `app/models/`, namespacing, concerns, custom validators. |
| [`controllers.md`](controllers.md) | Web and API controller organization, module prefixes, request flow. |
| [`views.md`](views.md) | View templates, helpers, assets, and partials. |
| [`lib.md`](lib.md) | Why `lib/` is legacy and where new code should go instead. |
| [`components.md`](components.md) | `components/` directory — UI isolation only, no business logic. |
| [`engines.md`](engines.md) | The API engine at `engines/api/`, versioning, what stays out. |
| [`background_jobs.md`](background_jobs.md) | Custom `Processor` job system; `lib/job_*.rb` exception for business logic. |
| [`database.md`](database.md) | MySQL conventions, migration locations, Redis usage. |
| [`connections.md`](connections.md) | AR connection types (main, setup, archive, replica), shard group naming, Rails connection switching, `Shards` class API. |
| [`sharding.md`](sharding.md) | Multi-tenant sharding at the Organization level. |
| [`deployment.md`](deployment.md) | Capistrano + Passenger deployment, CI/CD pipeline. |
| [`naming_conventions.md`](naming_conventions.md) | Naming standards for Ruby, database, and Zeitwerk autoload. |
| [`tests.md`](tests.md) | Test directory structure (RSpec primary, Minitest legacy). Behavioral testing rules live in [`./rules/testing/`](../testing/). |
| [`feature_toggle.md`](feature_toggle.md) | Integrating `PlanSource::FeatureToggle` for safe-update Feature Toggle strategy: toggle name, migration template, usage patterns, rules. |
| [`feature_toggle_cleanup.md`](feature_toggle_cleanup.md) | Enabling toggles in dev/test; toggle removal during the Cleanup story. |
