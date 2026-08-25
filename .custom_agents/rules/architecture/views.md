---
paths:
  - "app/views/**"
  - "components/*/app/views/**"
last_reviewed: 2026-05-19
---

# Views and Assets

View templates, helpers, and frontend assets.

---

## Views

Location: `app/views/`

ERB templates organized by controller:

```
app/views/
├── layouts/
│   └── application.html.erb
├── shared/                      # Shared partials
│   └── _navigation.html.erb
├── users/
│   ├── index.html.erb
│   ├── show.html.erb
│   └── _form.html.erb          # Partial
```

---

## Helpers

Location: `app/helpers/`

View helper modules provide formatting and presentation logic:

```ruby
# app/helpers/users_helper.rb
module UsersHelper
  def formatted_status(user)
    # ...
  end
end
```

Helpers are auto-included in views matching their name. `ApplicationHelper` is available everywhere.

---

## Assets

Location: `app/assets/`

```
app/assets/
├── javascripts/
│   └── application.js
├── stylesheets/
│   └── application.css
└── images/
```

---

## Partials

Use partials for reusable view components:

```erb
<%= render "shared/user_card", user: @user %>
<%= render partial: "form", locals: { enrollment: @enrollment } %>
```

Partial files start with underscore: `_form.html.erb`
