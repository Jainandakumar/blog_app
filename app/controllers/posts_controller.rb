class PostsController < ApplicationController
  before_action :set_post, only: %i[ show edit update destroy ]

  def index
    @posts = Post.includes(:user, :post_ratings).order(created_at: :desc)
  end

  def show
    @comment = Comment.new
    @comments = @post.comments.includes(:comment_ratings).order(created_at: :asc)
    @post_ratings = @post.post_ratings.to_a
  end

  def new
    @post = Post.new
    @users = User.order(:name)
  end

  def edit
    @users = User.order(:name)
  end

  def create
    @post = Post.new(post_params)

    if @post.save
      redirect_to @post, notice: "Post was successfully created."
    else
      @users = User.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @post.update(post_params)
      redirect_to @post, notice: "Post was successfully updated."
    else
      @users = User.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
    redirect_to posts_url, notice: "Post was successfully deleted."
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :body, :user_id)
  end
end
