# Tech Context

## Technologies Used
- **Ruby on Rails** 7.2.3
- **Ruby** (see `.ruby-version`)
- **SQLite3** — database (development & test)
- **Puma** — web server
- **Importmap-rails** — JavaScript without bundler
- **Sprockets** — asset pipeline for CSS
- **Turbo** (via Hotwire, included with Rails 7) — SPA-like navigation

## Development Setup
```bash
bin/setup          # install deps + prepare DB
bin/rails db:seed  # load sample data
bin/rails server   # start dev server at http://localhost:3000
```

## Database Schema
| Table    | Columns                                      |
|----------|----------------------------------------------|
| users    | id, name:string, email:string, timestamps    |
| posts    | id, title:string, body:text, user_id:integer, timestamps |
| comments | id, body:text, post_id:integer, timestamps   |

## Key Files
| File | Purpose |
|------|---------|
| `config/routes.rb` | Route definitions — root, users, posts + nested comments |
| `app/models/` | User, Post, Comment with associations & validations |
| `app/controllers/posts_controller.rb` | Full CRUD for posts |
| `app/controllers/comments_controller.rb` | Create/destroy comments scoped to post |
| `app/views/posts/` | All post views + partials |
| `app/views/comments/` | Comment partial + form partial |
| `app/assets/stylesheets/application.css` | All application styles (no external framework) |

## Technical Constraints
- No authentication/authorization (any user can author/delete any post)
- No pagination (all posts loaded on index)
- SQLite only (not suitable for multi-process production without change)
