class TopicsController < ApplicationController
  before_action :set_topic, only: [ :show, :edit, :update, :destroy ]
  before_action :require_owner, only: [ :edit, :update, :destroy ]

  def show
    @topic = current_condominium.topics.includes(:user, comments: :user).find(params[:id])
    @comment = Comment.new
  end

  def create
    @topic = current_condominium.topics.new(topic_params)
    @topic.user = current_user

    if @topic.save
      redirect_to dashboard_path(tab: @topic.topic_type == "announcement" ? "announcements" : "discussions"), notice: t("flash.topics.create_success")
    else
      redirect_to dashboard_path(tab: @topic.topic_type == "announcement" ? "announcements" : "discussions"), alert: @topic.errors.full_messages.to_sentence
    end
  end

  def edit
  end

  def update
    if @topic.update(topic_params)
      redirect_to @topic, notice: t("flash.topics.update_success")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @topic.destroy
    redirect_to dashboard_path, notice: t("flash.topics.destroy_success")
  end

  private

  def set_topic
    @topic = current_condominium.topics.find(params[:id])
  end

  def require_owner
    unless @topic.editable_by?(current_user)
      redirect_to dashboard_path, alert: t("flash.topics.not_authorized")
    end
  end

  def topic_params
    params.expect(topic: [ :title, :content, :topic_type ])
  end
end
