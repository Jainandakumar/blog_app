# Clear existing data
Comment.destroy_all
Post.destroy_all
User.destroy_all

# Create users
alice = User.create!(name: "Alice Smith", email: "alice@example.com")
bob   = User.create!(name: "Bob Jones",  email: "bob@example.com")

# Create posts
post1 = Post.create!(
  title: "Welcome to the Blog!",
  body: "This is the first post on our new blog application. We're excited to share ideas, stories, and insights with you. Stay tuned for more content coming soon!",
  user: alice
)

post2 = Post.create!(
  title: "Getting Started with Ruby on Rails",
  body: "Ruby on Rails is a fantastic web framework that makes building web applications fast and enjoyable. In this post we'll explore the basics of MVC, routing, and Active Record associations.",
  user: bob
)

post3 = Post.create!(
  title: "Why Comments Matter",
  body: "User engagement is key to a healthy blog. Enabling readers to leave comments fosters community and discussion. This post explores best practices for comment moderation.",
  user: alice
)

# Create comments
Comment.create!(post: post1, body: "Great first post! Looking forward to reading more.")
Comment.create!(post: post1, body: "Welcome! This blog looks promising.")
Comment.create!(post: post2, body: "Rails is amazing. Thanks for the intro!")
Comment.create!(post: post3, body: "Totally agree — comments bring a blog to life!")

puts "Seeded #{User.count} users, #{Post.count} posts, #{Comment.count} comments."
