class PostRatingsController < ApplicationController
  before_action :set_post

  def create
    @rating = @post.post_ratings.find_or_initialize_by(user_id: post_rating_params[:user_id])
    @rating.value = post_rating_params[:value]

    if @rating.save
      redirect_to @post, notice: "Your reaction was saved."
    else
      redirect_to @post, alert: "Could not save reaction: #{@rating.errors.full_messages.to_sentence}."
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def post_rating_params
    params.require(:post_rating).permit(:user_id, :value)
  end
end
