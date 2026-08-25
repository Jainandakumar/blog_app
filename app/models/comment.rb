class Comment < ApplicationRecord
  belongs_to :post
  has_many :comment_ratings, dependent: :destroy

  validates :body, presence: true
end
