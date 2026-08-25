# Progress

## What Works
- ✅ User CRUD (pre-existing, name + email)
- ✅ Post CRUD — create, read, update, delete
- ✅ Post index — lists all posts newest-first with author, date, comment count, truncated preview
- ✅ Post show — full post content + all comments + add comment form
- ✅ Post new/edit — form with author selector (dropdown of users), title, body
- ✅ Comments — create (from post show page) and delete
- ✅ User show — displays user's posts
- ✅ Navigation header with links
- ✅ Flash notices on all actions
- ✅ Confirmation dialogs on delete actions
- ✅ Validations on all models
- ✅ Seed data (2 users, 3 posts, 4 comments)

## What's Left to Build
- ❌ Authentication / authorization (currently open to all)
- ❌ Comment author name
- ❌ Post pagination
- ❌ Tags / categories
- ❌ Search
- ❌ Rich text editor for post body

## Current Status
**Feature complete for MVP** — the app can be started with `bin/rails server` and used immediately.

## Known Issues
- No authentication — anyone can edit or delete any post/comment
- Comments are anonymous (no author field)
- Deleting a user cascades to delete their posts and those posts' comments
