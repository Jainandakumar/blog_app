class CommentRating < ApplicationRecord
  belongs_to :user
  belongs_to :comment

  validates :value, presence: true, inclusion: { in: 1..5 }
  validates :user_id, uniqueness: { scope: :comment_id, message: "has already rated this comment" }
end
