# Validation Report — MDP-7

## Overall: PASS — all requirements are build_new (no parity conflicts, no blockers)

## Codebase Parity

- requirement: User can rate any comment using a star rating
  existing_code: none
  sibling_ticket: none
  blocker_deviation: matches (no blockers)
  recommendation: build_new

- requirement: A rating, once given, can be changed at any time
  existing_code: none
  sibling_ticket: none
  blocker_deviation: matches (no blockers)
  recommendation: build_new

- requirement: Star rating UI is presented on comments
  existing_code: none
  sibling_ticket: none
  blocker_deviation: matches (no blockers)
  recommendation: build_new

## Existing Structure

- `comments` table: id, body, post_id, created_at, updated_at — no rating columns
- `Comment` model: belongs_to :post, validates :body presence — no rating associations
- `CommentsController`: create + destroy only — no rate action
- Routes: `resources :comments, only: %i[create destroy]` — no rating routes
- Views: `_comment.html.erb` — no stars/rating UI

## What needs to be built

1. `comment_ratings` table: user_id, comment_id, value (1-5), unique index on [user_id, comment_id]
2. `CommentRating` model with validations and associations
3. `Comment` model association: has_many :comment_ratings
4. `User` model association: has_many :comment_ratings
5. `CommentRatingsController` with upsert action (create or update)
6. Route: `resources :comments, only: %i[create destroy] { resources :comment_ratings, only: [:create] }`
7. Star rating UI partial in comment view (5-star CSS/HTML, submit on click)
8. Migration

## Blockers

None.

## Sibling tickets

Not applicable (Idea type).
