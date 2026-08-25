---
last_reviewed: 2026-05-19
---

# Deployment

Deployment architecture and CI/CD.

---

## Important

**NOT using Docker currently.**

This application deploys to physical servers via Capistrano.

---

## Deployment Stack

| Component | Technology |
|-----------|------------|
| Deployment tool | Capistrano |
| Web server | Passenger |
| Application server | Puma |
| Target | Physical/VM servers |

---

## Deployment Process

1. Code is deployed via Capistrano
2. Runs on physical/VM servers
3. Passenger serves the Rails application
4. Background jobs managed by internal system

---

## Environments

| Environment | Purpose |
|-------------|---------|
| Development | Local database, local Redis |
| Staging | Production-like, separate database, QA testing |
| Production | Multi-server, load balancer |

---

## CI/CD Pipeline

**Platform:** GitHub CI

**Pipeline stages:**
1. Build - Install dependencies
2. Lint - Pronto/RuboCop, RubyCritic, Reek, Brakeman, erb_lint
3. Test - RSpec (full suite), Minitest
4. Security - bundler-audit, vulnerability scans
5. Deploy to staging (via Capistrano)
6. Deploy to production (manual approval, via Capistrano)

See `.github-ci.yml` for current configuration.

**Note:** CI runs full test suite (takes significant time). Developers run targeted tests locally.

---

## Application Server Configuration

**Puma settings:**
- Workers: Configured via ENV or `config/puma.rb`
- Threads: `RAILS_MAX_THREADS` environment variable
- Port: 3000 (default)

---

## Database Connections

- Pool size matches thread count
- Configured in `config/database.yml`
- Migrations run before deployment

---

## Future Consideration

Docker may be adopted later, but is not current architecture.
