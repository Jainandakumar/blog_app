# Product Context

## Why This Project Exists
A simple blog application to demonstrate and practice Rails MVC patterns, model associations, nested resources, and basic CRUD operations.

## Problems It Solves
- Gives users a platform to write and publish blog posts
- Enables reader engagement through comments on posts
- Provides user management to track authorship

## How It Should Work
1. **Users** are created with a name and email
2. **Posts** are created by selecting an author (user), giving it a title and body text
3. **Post listing** (home page) shows all posts in reverse chronological order with truncated preview
4. **Post detail page** shows the full post + all comments + a comment form
5. **Comments** are added via a form on the post show page; they can be deleted
6. **User profile** shows the user's details and all their posts

## User Experience Goals
- Clean, readable layout with no external CSS framework dependency
- Flash notices for all create/update/delete actions
- Confirmation dialogs before destructive operations (delete post, delete comment)
- Navigation header always visible with links to Posts, New Post, Users
