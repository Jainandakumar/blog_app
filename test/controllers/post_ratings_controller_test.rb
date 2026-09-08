require "test_helper"

class PostRatingsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    @post = posts(:one)
  end

  test "creates a new like successfully" do
    assert_difference "PostRating.count", 1 do
      post post_post_ratings_url(@post),
           params: { post_rating: { user_id: @user.id, value: 1 } }
    end
    assert_redirected_to @post
    assert_equal "Your reaction was saved.", flash[:notice]
  end

  test "creates a new dislike successfully" do
    assert_difference "PostRating.count", 1 do
      post post_post_ratings_url(@post),
           params: { post_rating: { user_id: @user.id, value: -1 } }
    end
    assert_redirected_to @post
    assert_equal "Your reaction was saved.", flash[:notice]
  end

  test "updates an existing rating (upsert — like to dislike)" do
    existing = PostRating.create!(user: @user, post: @post, value: 1)

    assert_no_difference "PostRating.count" do
      post post_post_ratings_url(@post),
           params: { post_rating: { user_id: @user.id, value: -1 } }
    end

    assert_redirected_to @post
    assert_equal -1, existing.reload.value
  end

  test "updates an existing rating (upsert — dislike to like)" do
    existing = PostRating.create!(user: @user, post: @post, value: -1)

    assert_no_difference "PostRating.count" do
      post post_post_ratings_url(@post),
           params: { post_rating: { user_id: @user.id, value: 1 } }
    end

    assert_redirected_to @post
    assert_equal 1, existing.reload.value
  end

  test "rejects invalid value and redirects with alert" do
    assert_no_difference "PostRating.count" do
      post post_post_ratings_url(@post),
           params: { post_rating: { user_id: @user.id, value: 5 } }
    end
    assert_redirected_to @post
    assert flash[:alert].present?
  end

  test "rejects missing user_id" do
    assert_no_difference "PostRating.count" do
      post post_post_ratings_url(@post),
           params: { post_rating: { user_id: nil, value: 1 } }
    end
    assert_redirected_to @post
    assert flash[:alert].present?
  end

  test "two different users can rate the same post independently" do
    user2 = users(:two)
    assert_difference "PostRating.count", 2 do
      post post_post_ratings_url(@post),
           params: { post_rating: { user_id: @user.id, value: 1 } }
      post post_post_ratings_url(@post),
           params: { post_rating: { user_id: user2.id, value: -1 } }
    end
  end
end
