require "test_helper"

class CommentRatingTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @post = posts(:one)
    @comment = comments(:one)
  end

  test "is valid with value in 1..5" do
    rating = CommentRating.new(user: @user, comment: @comment, value: 3)
    assert rating.valid?
  end

  test "is invalid without a value" do
    rating = CommentRating.new(user: @user, comment: @comment, value: nil)
    assert_not rating.valid?
    assert_includes rating.errors[:value], "can't be blank"
  end

  test "is invalid with value below 1" do
    rating = CommentRating.new(user: @user, comment: @comment, value: 0)
    assert_not rating.valid?
  end

  test "is invalid with value above 5" do
    rating = CommentRating.new(user: @user, comment: @comment, value: 6)
    assert_not rating.valid?
  end

  test "enforces uniqueness of user_id scoped to comment_id" do
    CommentRating.create!(user: @user, comment: @comment, value: 4)
    duplicate = CommentRating.new(user: @user, comment: @comment, value: 2)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "has already rated this comment"
  end

  test "two different users can rate the same comment" do
    user2 = users(:two)
    CommentRating.create!(user: @user, comment: @comment, value: 5)
    rating2 = CommentRating.new(user: user2, comment: @comment, value: 3)
    assert rating2.valid?
  end
end
