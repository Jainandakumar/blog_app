---
paths:
  - "app/views/**"
  - "components/*/app/views/**"
last_reviewed: 2026-05-19
---

# Security: UI and views

Security guidelines for views, templates, and frontend code.

---

## Cross-Site Scripting (XSS) Prevention

XSS occurs when user input is rendered without escaping, allowing script injection.

### ERB Auto-Escapes by Default

```erb
<!-- SAFE - ERB escapes automatically -->
<%= user.name %>
<%= @comment.body %>

<!-- The above renders special characters as HTML entities -->
<!-- <script> becomes &lt;script&gt; -->
```

### Never Use html_safe or raw on User Content

```erb
<!-- VULNERABLE -->
<%= raw user.bio %>
<%= user.content.html_safe %>

<!-- These render unescaped HTML, allowing XSS -->
```

### Sanitize When HTML Is Needed

```erb
<!-- If you must allow some HTML, sanitize it -->
<%= sanitize(user.bio, tags: %w[p br strong em a], attributes: %w[href]) %>
```

### JavaScript Context Requires JSON Encoding

```erb
<!-- VULNERABLE - direct interpolation in JS -->
<script>
  var name = "<%= @user.name %>";  // XSS if name contains quotes/script
</script>

<!-- SAFE - JSON encoding -->
<script>
  var name = <%= @user.name.to_json %>;
  var userData = <%= @user.slice(:id, :name).to_json %>;
</script>
```

---

## Output Encoding by Context

Different contexts require different encoding:

| Context | Method | Example |
|---------|--------|---------|
| HTML body | ERB default | `<%= value %>` |
| HTML attribute | ERB default | `<div title="<%= value %>">` |
| JavaScript | `.to_json` | `var x = <%= value.to_json %>;` |
| URL | `url_encode` | `?q=<%= url_encode(value) %>` |
| CSS | Avoid user input | Don't interpolate in CSS |

---

## URL Safety in Views

```erb
<!-- Good - Rails generates safe URLs -->
<%= link_to "Profile", user_path(@user) %>

<!-- Be careful with user-provided URLs -->
<%= link_to "Website", @user.website if valid_url?(@user.website) %>
```

---

## Form Security

### Authorization data is set server-side

Hidden fields are not authoritative. Authorization decisions must be made on the server using session/auth state, not values round-tripped through the form:

```erb
<!-- WRONG -->
<%= hidden_field_tag :user_id, current_user.id %>
```

Use `current_user` in the controller, not a hidden field.

---

## View-Level Authorization

Use Pundit policies to show/hide UI elements based on permissions:

```erb
<%# Only show edit link if user has permission %>
<% if policy(@document).edit? %>
  <%= link_to "Edit", edit_document_path(@document) %>
<% end %>

<%# Conditionally render action buttons %>
<% if policy(@enrollment).cancel? %>
  <%= button_to "Cancel Enrollment", cancel_enrollment_path(@enrollment), method: :post %>
<% end %>
```

**Important:** View-level checks are for UX only. Always enforce authorization at the controller level too - users can bypass UI restrictions. See [api.md](api.md) for the controller-level rules.

---

## Client-Side Validation and Security

Client-side validation can be bypassed. Always validate on the server:

```ruby
# Even if the form validates email format client-side
validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
```

See [business_logic.md](business_logic.md) for model-level validation rules.

---

## Related

- [overview.md](overview.md) — Universal principles (whitelist, defense in depth).
- [api.md](api.md) — Controller-level authorization that view-level checks must mirror.
- [business_logic.md](business_logic.md) — Server-side validation that client-side validation does NOT replace.
- [../architecture/views.md](../architecture/views.md) — View organization.
- [../style/ui.md](../style/ui.md) — Style for views and ERB conventions.
