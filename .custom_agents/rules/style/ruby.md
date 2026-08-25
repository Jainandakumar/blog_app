---
paths:
  - "**/*.rb"
last_reviewed: 2026-05-19
---

# Ruby style rules

Idiomatic Ruby usage: strings, hashes, arrays, conditionals, methods, blocks.

---

## String Literals

Use double quotes. Single quotes only to avoid escaping.

```ruby
name = "John Doe"
message = 'He said "hello"'  # Acceptable to avoid escaping
```

---

## String Interpolation

Prefer interpolation over concatenation.

```ruby
# Good
"Hello, #{user.name}!"

# Bad
"Hello, " + user.name + "!"
```

---

## Hash Syntax

Ruby 1.9+ syntax for symbol keys.

```ruby
user = { name: "John", age: 30 }
config = { "api_key" => "abc123" }  # String keys use hashrocket
```

---

## Arrays

Use `%w[]` for string arrays, `%i[]` for symbol arrays.

```ruby
STATES = %w[pending approved rejected]
STATUSES = %i[active inactive suspended]
```

---

## Conditionals

Use `&&` and `||`, not `and` and `or`. Prefer guard clauses.

```ruby
# Good
return unless user.valid?

if user.present? && user.active?
  process_user(user)
end

# Bad
if user.present? and user.active?  # Don't use 'and'
```

---

## Methods

Parentheses required for methods with parameters.

```ruby
def greet(name)
  "Hello, #{name}!"
end

def full_name
  "#{first_name} #{last_name}"
end
```

---

## Blocks

`{...}` for single-line, `do...end` for multi-line.

```ruby
names.map { |name| name.upcase }

names.each do |name|
  puts name
  process_name(name)
end
```

---

## Related

- [`essentials.md`](essentials.md) — formatting basics (quotes/indentation/line length).
- [`naming.md`](naming.md) — naming standards.
- [`linters.md`](linters.md) — how these rules are enforced.
