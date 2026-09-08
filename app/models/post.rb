class Post < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :post_ratings, dependent: :destroy

  validates :title, presence: true
  validates :body, presence: true
end
