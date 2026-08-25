class CommentRatingsController < ApplicationController
  before_action :set_post
  before_action :set_comment

  def create
    @rating = @comment.comment_ratings.find_or_initialize_by(user_id: comment_rating_params[:user_id])
    @rating.value = comment_rating_params[:value]

    if @rating.save
      redirect_to @post, notice: "Rating saved successfully."
    else
      redirect_to @post, alert: "Could not save rating: #{@rating.errors.full_messages.to_sentence}."
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def set_comment
    @comment = @post.comments.find(params[:comment_id])
  end

  def comment_rating_params
    params.require(:comment_rating).permit(:user_id, :value)
  end
end
