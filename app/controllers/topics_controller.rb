class TopicsController < ApplicationController
  def show
    @topic = current_condominium.topics.includes(:user, comments: :user).find(params[:id])
    @comment = Comment.new
  end

  def create
    @topic = current_condominium.topics.new(topic_params)
    @topic.user = current_user

    if @topic.save
      redirect_to root_path(tab: @topic.topic_type == "announcement" ? "announcements" : "topics"), notice: "Post created successfully."
    else
      redirect_to root_path(tab: @topic.topic_type == "announcement" ? "announcements" : "topics"), alert: @topic.errors.full_messages.to_sentence
    end
  end

  private

  def topic_params
    params.require(:topic).permit(:title, :content, :topic_type)
  end
end
