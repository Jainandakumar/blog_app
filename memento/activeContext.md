# Active Context

## Current Work Focus
Posts and Comments feature has been fully implemented. The app is ready to run.

## What Was Just Done
- Generated and ran migrations for `posts` and `comments` tables
- Created `Post` model (`belongs_to :user`, `has_many :comments`)
- Created `Comment` model (`belongs_to :post`)
- Updated `User` model (`has_many :posts`)
- Created `PostsController` with full 7-action CRUD
- Created `CommentsController` with `create` and `destroy` (nested under posts)
- Updated `config/routes.rb` — root set to `posts#index`, posts with nested comments
- Created all post views: `index`, `show`, `new`, `edit`, `_post`, `_form`
- Created comment views: `_comment`, `_form`
- Updated `app/views/layouts/application.html.erb` with nav header + flash notices
- Updated `app/views/users/show.html.erb` to list user's posts
- Added styled `application.css` (no external framework)
- Seeded 2 users, 3 posts, 4 comments

## Next Steps
- Add authentication (e.g., Devise) so only the author can edit/delete their posts
- Add pagination for the posts index (e.g., Pagy or Kaminari)
- Add commenter name field to Comment model
- Consider adding tags/categories for posts

## Active Decisions
- No authentication — any visitor can create/edit/delete any post or comment
- Comments do not have an author field (anonymous)
- Styling is hand-written CSS, no Tailwind or Bootstrap
