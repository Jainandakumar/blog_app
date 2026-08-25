---
paths:
  - "app/views/**"
  - "components/*/app/views/**"
last_reviewed: 2026-05-19
---

# Style: UI & Views

Guidelines for views, ERB templates, and frontend code.

---

## View Guidelines

### Avoid Logic in Views

Move logic to helpers or presenters:

```erb
<!-- Bad - logic in view -->
<% if @user.active? && @user.role == "admin" && @user.approved? %>
  <%= @user.name.upcase %> - <%= @user.created_at.strftime("%B %d, %Y") %>
<% end %>

<!-- Good - use helper -->
<%= formatted_user_display(@user) if @user.can_manage? %>
```

### Use Partials for Reusable Components

```erb
<!-- Good -->
<%= render "shared/user_card", user: @user %>
<%= render partial: "form", locals: { enrollment: @enrollment } %>

<!-- Bad - duplicated markup across views -->
```

### Prefer Rails Helpers Over Raw HTML

```erb
<!-- Good -->
<%= link_to "View Profile", user_path(@user), class: "btn" %>
<%= form_with model: @user do |f| %>

<!-- Avoid -->
<a href="/users/<%= @user.id %>">View Profile</a>
<form action="/users" method="post">
```

---

## Related

- [`../architecture/views.md`](../architecture/views.md) — view structure and where helpers/partials live.
- [`../security/ui.md`](../security/ui.md) — XSS, output encoding.
