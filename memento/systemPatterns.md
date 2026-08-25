# System Patterns

## Architecture
Standard Rails MVC (Model-View-Controller) monolith.

## Model Associations

```
User
 └── has_many :posts (dependent: :destroy)

Post
 ├── belongs_to :user
 └── has_many :comments (dependent: :destroy)

Comment
 └── belongs_to :post
```

## Key Technical Decisions

### Nested Resources
Comments are nested under posts in routes:
```
resources :posts do
  resources :comments, only: [:create, :destroy]
end
```
This gives URLs like `/posts/:post_id/comments` and `/posts/:post_id/comments/:id`.

### Controller Pattern
- `PostsController` — full 7-action CRUD
- `CommentsController` — only `create` and `destroy`, always scoped through `@post`
- Both use `before_action` to set parent resource

### View Partials
- `posts/_post.html.erb` — card used on index listing
- `posts/_form.html.erb` — shared new/edit form
- `comments/_comment.html.erb` — single comment row
- `comments/_form.html.erb` — new comment form rendered on post show page

### Flash Notices
All create/update/destroy actions redirect with `notice:` flash messages displayed in the layout.

### Validations
- `User`: name presence, email presence + uniqueness
- `Post`: title presence, body presence
- `Comment`: body presence
