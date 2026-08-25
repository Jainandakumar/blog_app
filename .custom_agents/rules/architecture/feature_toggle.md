---
last_reviewed: 2026-05-19
---

# Feature toggle integration (`PlanSource::FeatureToggle`)

Reference for integrating feature toggles using the `PlanSource::FeatureToggle` gem
(a wrapper around Ruby Flipper). Read this when the implementation plan specifies
a Feature Toggle safe update strategy.

**YARD:** Toggle integration in models/services follows YARD per
`./rules/yard/README.md`.

For enabling toggles in dev/test and the cleanup-story removal procedure, see
[feature_toggle_cleanup.md](feature_toggle_cleanup.md).

## Critical: toggle name

The toggle name **must be provided in the ticket or plan.** All stories in a Feature share
the same toggle name — it was defined during `/planning`.

- **If a toggle name is provided:** use it exactly as specified
- **If no toggle name is found:** return `NEEDS_DECISION` — do not invent a toggle name

## Before creating a toggle

**Always check if the toggle already exists** before creating a data migration:

- Use the Grep tool to search for `FeatureToggle[:toggle_name]` in `app/`, `config/`, and `lib/`
- Use the Grep tool to search for `toggle_name` in `db/data/` to check for existing data migrations

If the toggle already exists, skip creation and go straight to usage.

## Creating a new toggle (data migration)

Feature toggles are created via **data migrations** in `db/data/`, not schema migrations.
Use `date +%Y%m%d%H%M%S` for the timestamp (never guess the time).

### Migration template

```ruby
# frozen_string_literal: true

# This class creates feature toggle ':toggle_name' for [description]
class AddToggleNameFeatureToggle < ActiveRecord::Migration[7.2]
  FEATURE_TOGGLE = "toggle_name"

  def up
    User.current_process = "Migration #{self.class.name} UP"
    return unless AppConfig.is_catalog?
    return if PlanSource::FeatureToggle::Ar::FeatureToggle.exists?(key: FEATURE_TOGGLE)

    PlanSource::FeatureToggle::Ar::FeatureToggle.create!(key: FEATURE_TOGGLE)

    FeatureToggleDetail.create_or_update_feature_toggle_detail(
      feature_key: FEATURE_TOGGLE,
      description: "DESCRIPTION_HERE",
      team_owner: "TEAM_NAME",
      creation_ticket: "https://plansource.atlassian.net/browse/MDP-NNNNNN",
      intended_applied_to: "per_organization"
    )
  end

  def down
    User.current_process = "Migration #{self.class.name} DOWN"
    return unless AppConfig.is_catalog?
    return unless PlanSource::FeatureToggle::Ar::FeatureToggle.exists?(key: FEATURE_TOGGLE)

    PlanSource::FeatureToggle::Ar::FeatureToggle.where(key: FEATURE_TOGGLE).destroy_all
    PlanSource::FeatureToggle::Ar::FeatureToggleGate.where(feature_key: FEATURE_TOGGLE).destroy_all
    FeatureToggleDetail.where(feature_key: FEATURE_TOGGLE).destroy_all
  end
end
```

### `FeatureToggleDetail` fields

| Field | Required | Description |
|-------|----------|-------------|
| `feature_key` | Yes | The toggle name (matches FEATURE_TOGGLE constant) |
| `description` | Yes | What this toggle controls |
| `team_owner` | Yes | Team responsible for this toggle |
| `creation_ticket` | No | Jira ticket URL that created the toggle |
| `removal_ticket` | No | Jira ticket URL for cleanup/removal |
| `intended_applied_to` | Yes | Scope: `per_organization`, `per_user`, or `global` |

## Using a toggle

### In model/service code (most common)

Pass the per-entity actor (user or organization) to `enabled?`. For a global
check (no actor), call `enabled?` with no argument.

```ruby
if PlanSource::FeatureToggle[:toggle_name].enabled?(user) # or organization, or no arg for global
  # New behavior
else
  # Old behavior (must remain fully functional)
end
```

### In routes

Use route constraints to toggle entire route sets:

```ruby
# Standard constraint (checks current user)
constraints(PlanSource::FeatureToggle::RailsRouteConstraint.new(:toggle_name)) do
  resources :new_feature
end

# BenAdmin constraint (for ben_admin context)
constraints(PlanSource::FeatureToggle::BenAdminRouteConstraint.new(:toggle_name)) do
  resources :new_feature
end

# With additional logic
constraints(PlanSource::FeatureToggle::RailsRouteConstraint.new(:toggle_name) { |user| user.admin? }) do
  resources :admin_feature
end
```

### In views/helpers

```ruby
def show_new_feature?(user)
  PlanSource::FeatureToggle[:toggle_name].enabled?(user)
end
```

## Implementation rules

1. **Both paths must work.** When the toggle is OFF, the old behavior must be 100%
   functional. When the toggle is ON, the new behavior must work correctly. Never
   leave the old path broken.

2. **Toggle checks at the boundary.** Place toggle checks at the highest appropriate
   level (controller action, route constraint, service entry point) — not deep
   inside methods. This keeps the toggle's blast radius visible and makes cleanup
   easier.

3. **Don't nest toggles.** One toggle per feature. If you find yourself checking the
   same toggle in multiple nested locations, refactor to check once at the entry point.

4. **Tests cover both paths.** Write tests for toggle ON and toggle OFF:

   ```ruby
   context "when :toggle_name is enabled" do
     before { PlanSource::FeatureToggle[:toggle_name].enable }
     # or for per-actor: PlanSource::FeatureToggle[:toggle_name].enable_actor(organization)

     it "uses new behavior" do
       # ...
     end
   end

   context "when :toggle_name is disabled" do
     before { PlanSource::FeatureToggle[:toggle_name].disable }

     it "uses old behavior" do
       # ...
     end
   end
   ```

5. **Cleanup is a separate ticket.** Do not remove toggle checks in the same ticket
   that adds them. The Cleanup story (created during planning) handles removal after
   cutover is verified. See [feature_toggle_cleanup.md](feature_toggle_cleanup.md).

## Output format

When a code agent integrates a toggle, include this summary block in its
output (alongside the universal code-agent Output Format from
`./rules/agent_authoring/code_implementation.md`):

```
## Feature Toggle Integration

Toggle: :toggle_name
Action: [created | already exists — using existing]
Data migration (if created): db/data/TIMESTAMP_add_toggle_name_feature_toggle.rb
Toggle checks added: [count] in [files]
Tests updated: [test file] (toggle ON/OFF contexts added)
```
