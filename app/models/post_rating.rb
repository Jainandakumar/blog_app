class PostRating < ApplicationRecord
  belongs_to :user
  belongs_to :post

  validates :value, presence: true, inclusion: { in: [1, -1], message: "must be 1 (like) or -1 (dislike)" }
  validates :user_id, uniqueness: { scope: :post_id, message: "has already rated this post" }
end
