# Implementation Plan — MDP-7: Comment Star Rating

## Ticket Summary
Users can rate any comment with a 1–5 star rating. A rating can be changed at any time (upsert semantics).

## Tech Context
- Rails 7.2, SQLite, importmap (no Webpacker)
- No authentication system (no current_user / devise)
- Users exist in DB but no session — rating form will include user selector
- Existing comment pattern: belongs_to :post, no user association on Comment

## Architecture Decision
Since there's no auth, the rating form will present a user selector (consistent with how the app handles user-owned content). The rating is upserted per (user_id, comment_id) pair.

## Files to Create / Modify

### New Files

1. **`db/migrate/[timestamp]_create_comment_ratings.rb`**
   - Table: `comment_ratings`
   - Columns: `id`, `user_id` (integer, not null), `comment_id` (integer, not null), `value` (integer, not null)
   - Unique index on `[user_id, comment_id]`
   - FK: user_id → users, comment_id → comments

2. **`app/models/comment_rating.rb`**
   - `belongs_to :user`
   - `belongs_to :comment`
   - `validates :value, presence: true, inclusion: { in: 1..5 }`
   - `validates :user_id, uniqueness: { scope: :comment_id }`

3. **`app/controllers/comment_ratings_controller.rb`**
   - `before_action :set_post`, `set_comment`
   - `create` action: upsert (find_or_initialize_by user_id + comment_id, set value, save)
   - Redirect back to post on success/failure
   - Routed as nested: `posts/:post_id/comments/:comment_id/comment_ratings`

4. **`app/views/comment_ratings/_form.html.erb`**
   - Star rating form: 5 radio buttons styled as stars
   - User selector (select from User.all)
   - Submits to `post_comment_comment_ratings_path`

### Modified Files

5. **`app/models/comment.rb`**
   - Add `has_many :comment_ratings, dependent: :destroy`

6. **`app/models/user.rb`**
   - Add `has_many :comment_ratings, dependent: :destroy`

7. **`config/routes.rb`**
   - Nest `resources :comment_ratings, only: [:create]` inside `resources :comments`

8. **`app/views/comments/_comment.html.erb`**
   - Add star display (average rating + count)
   - Render `comment_ratings/form` partial

9. **`app/assets/stylesheets/application.css`**
   - Add `.star-rating` styles (CSS-only 5-star widget with radio inputs)

## Acceptance Criteria Mapping
- ✅ AC1: User can rate any comment with stars → star form on each comment
- ✅ AC2: Rating can be changed → upsert in controller (find_or_initialize_by)
- ✅ AC3: Star rating UI on comments → `_form.html.erb` rendered in `_comment.html.erb`

## Safe Update Strategy
None specified. All new code — no existing behavior modified except model associations.

## Test Plan (Step 9)
- Model: `CommentRating` validations, uniqueness constraint
- Controller: create (new rating), create (update existing rating)
- Integration: end-to-end rating flow
