require "test_helper"

class CommentRatingsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    @post = posts(:one)
    @comment = comments(:one)
  end

  test "creates a new rating successfully" do
    assert_difference "CommentRating.count", 1 do
      post post_comment_comment_ratings_url(@post, @comment),
           params: { comment_rating: { user_id: @user.id, value: 4 } }
    end
    assert_redirected_to @post
    assert_equal "Rating saved successfully.", flash[:notice]
  end

  test "updates an existing rating (upsert)" do
    existing = CommentRating.create!(user: @user, comment: @comment, value: 2)

    assert_no_difference "CommentRating.count" do
      post post_comment_comment_ratings_url(@post, @comment),
           params: { comment_rating: { user_id: @user.id, value: 5 } }
    end

    assert_redirected_to @post
    assert_equal 5, existing.reload.value
  end

  test "rejects invalid value and redirects with alert" do
    assert_no_difference "CommentRating.count" do
      post post_comment_comment_ratings_url(@post, @comment),
           params: { comment_rating: { user_id: @user.id, value: 9 } }
    end
    assert_redirected_to @post
    assert flash[:alert].present?
  end

  test "rejects missing user_id" do
    assert_no_difference "CommentRating.count" do
      post post_comment_comment_ratings_url(@post, @comment),
           params: { comment_rating: { user_id: nil, value: 3 } }
    end
    assert_redirected_to @post
    assert flash[:alert].present?
  end
end
