class TopicsController < ApplicationController
  def show
    @topic = current_condominium.topics.includes(:user, comments: :user).find(params[:id])
    @comment = Comment.new
  end

  def create
    @topic = current_condominium.topics.new(topic_params)
    @topic.user = current_user

    if @topic.save
      redirect_to dashboard_path(tab: @topic.topic_type == "announcement" ? "announcements" : "topics"), notice: t("flash.topics.create_success")
    else
      redirect_to dashboard_path(tab: @topic.topic_type == "announcement" ? "announcements" : "topics"), alert: @topic.errors.full_messages.to_sentence
    end
  end

  private

  def topic_params
    params.require(:topic).permit(:title, :content, :topic_type)
  end
end
