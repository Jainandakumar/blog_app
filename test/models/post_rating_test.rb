require "test_helper"

class PostRatingTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @post = posts(:one)
  end

  test "is valid with value 1 (like)" do
    rating = PostRating.new(user: @user, post: @post, value: 1)
    assert rating.valid?
  end

  test "is valid with value -1 (dislike)" do
    rating = PostRating.new(user: @user, post: @post, value: -1)
    assert rating.valid?
  end

  test "is invalid without a value" do
    rating = PostRating.new(user: @user, post: @post, value: nil)
    assert_not rating.valid?
    assert_includes rating.errors[:value], "can't be blank"
  end

  test "is invalid with value 0" do
    rating = PostRating.new(user: @user, post: @post, value: 0)
    assert_not rating.valid?
  end

  test "is invalid with value 2" do
    rating = PostRating.new(user: @user, post: @post, value: 2)
    assert_not rating.valid?
  end

  test "enforces uniqueness of user_id scoped to post_id" do
    PostRating.create!(user: @user, post: @post, value: 1)
    duplicate = PostRating.new(user: @user, post: @post, value: -1)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "has already rated this post"
  end

  test "two different users can rate the same post" do
    user2 = users(:two)
    PostRating.create!(user: @user, post: @post, value: 1)
    rating2 = PostRating.new(user: user2, post: @post, value: -1)
    assert rating2.valid?
  end

  test "same user can rate different posts" do
    post2 = posts(:two)
    PostRating.create!(user: @user, post: @post, value: 1)
    rating2 = PostRating.new(user: @user, post: post2, value: -1)
    assert rating2.valid?
  end
end
