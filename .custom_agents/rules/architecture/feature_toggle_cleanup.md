---
last_reviewed: 2026-05-19
---

# Enabling and removing feature toggles

Companion to [feature_toggle.md](feature_toggle.md). Covers two operations that
happen *after* the toggle is integrated: enabling it for development/testing,
and removing it during the Cleanup story after cutover.

## Enabling a toggle (for development/testing)

Via rails console:

```ruby
# Enable for a specific organization
org = Organization.find(123)
PlanSource::FeatureToggle[:toggle_name].enable_actor(org)

# Enable for user_entity group (common pattern)
PlanSource::FeatureToggle[:toggle_name].enable_group(:user_entity)

# Enable globally (use with caution)
PlanSource::FeatureToggle[:toggle_name].enable
```

Via the admin UI: `http://<-url>/feature_toggle`

## Toggle removal (cleanup story)

The Cleanup story is a separate ticket created during planning. It runs after
the cutover is verified in production. Steps:

1. Remove all `PlanSource::FeatureToggle[:name].enabled?` checks — keep only the
   "ON" path.
2. Remove route constraints wrapping toggled routes.
3. Remove toggle-specific test contexts (keep the "enabled" tests as the new
   default).
4. Create a data migration to remove the toggle:

   ```ruby
   def up
     User.current_process = "Migration #{self.class.name} UP"
     return unless AppConfig.is_catalog?
     PlanSource::FeatureToggle::Ar::FeatureToggle.where(key: "toggle_name").destroy_all
     PlanSource::FeatureToggle::Ar::FeatureToggleGate.where(feature_key: "toggle_name").destroy_all
     FeatureToggleDetail.where(feature_key: "toggle_name").destroy_all
   end
   ```
