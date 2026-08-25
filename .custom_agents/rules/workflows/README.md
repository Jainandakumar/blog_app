---
last_reviewed: 2026-05-20
---

# Workflows — shared rule index

Shared workflow rules that more than one skill or agent reads. Single-skill
workflows live under `./skills/<skill>/workflows/` (e.g. `bugfix.md`
and `hotpatch.md` are bundled into the `develop` skill).

---

## Files in this folder

| File | Read when |
|---|---|
| [git.md](git.md) | Any work that touches branches, agent-ownership of git commands, or release flows. |
| [commits.md](commits.md) | Authoring a commit message; following the `MDP-NNNNNN` + Co-Authored-By trailer. |
| [merge_requests.md](merge_requests.md) | Creating, updating, or stacking merge requests. |
| [development.md](development.md) | Session UX patterns — when to prompt for branches, commits, MR splits; incomplete-feature strategies. |
| [legacy_code.md](legacy_code.md) | Editing a file whose surrounding code does NOT meet current guidelines. |
| [database.md](database.md) | Running migrations / data migrations / db reset / db console commands. |

For running tests, Pronto, or `bin/rspec-changed` operationally, see
[`../testing/running.md`](../testing/running.md).

---

## Daily development quick reference

These commands are the canonical "what do I run during the day" set. Each
subsection delegates to the right file above for the conventions.

### Start of day

```bash
git checkout develop
git pull origin develop
bundle install
bundle exec rake db:migrate          # see database.md if pending migrations
bundle exec rails server
```

### During development

1. Create feature branch — see [git.md](git.md) §Creating a Feature Branch.
2. Make changes; write tests — see [`../testing/running.md`](../testing/running.md).
3. Run targeted specs: `bundle exec rspec spec/path/to/spec.rb`.
4. Check style: `bundle exec pronto run --commit=origin/develop --runner=rubocop`.
5. Commit: see [commits.md](commits.md) for message format.

### End of day

```bash
git push origin MDP-NNNNNN_description
# Create merge request — see merge_requests.md
```

---

## Code review checklist

Before requesting review:

- [ ] All targeted tests pass (see [`../testing/running.md`](../testing/running.md))
- [ ] Pronto passes on changed lines
- [ ] Self-reviewed changes
- [ ] Tests added for new code
- [ ] Clear MR description (see [merge_requests.md](merge_requests.md))

When reviewing:

- [ ] Code follows style guidelines (see [../style/](../style/))
- [ ] Tests are present and meaningful (see [../testing/](../testing/))
- [ ] No security vulnerabilities (see [../security/](../security/))
- [ ] Edge cases handled

---

## Common one-off commands

```bash
# Rails generators
rails g model User name:string email:string
rails g migration AddStatusToUsers status:string
rails g controller Users index show
rails routes

# Rake
rake -T              # list all tasks
rake -T db           # list db tasks

# Debugging
tail -f log/development.log
rake log:clear
```

---

## Common issues

**Bundle install fails:**

```bash
gem update bundler
rm -rf vendor/bundle
bundle install
```

**Database connection errors:** see [database.md](database.md).

**Redis connection:**

```bash
redis-cli ping       # should return PONG
redis-server         # start Redis
```

**Tests failing randomly:**

```bash
RAILS_ENV=test bundle exec rake db:reset
```
