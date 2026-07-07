class CommentsController < ApplicationController
  before_action :set_topic
  before_action :set_comment, only: %i[ edit update destroy ]
  before_action :require_comment_owner, only: %i[ edit update destroy ]

  def create
    @comment = @topic.comments.new(comment_params)
    @comment.user = current_user

    if @comment.save
      redirect_to topic_path(@topic), notice: t("flash.comments.create_success")
    else
      redirect_to topic_path(@topic), alert: @comment.errors.full_messages.to_sentence
    end
  end

  def edit
    if turbo_frame_request?
      render partial: "topics/comment_form", locals: { topic: @topic, comment: @comment }
    else
      redirect_to topic_path(@topic, anchor: helpers.dom_id(@comment))
    end
  end

  def update
    if @comment.update(comment_params)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            @comment,
            partial: "topics/comment",
            locals: { topic: @topic, comment: @comment }
          )
        end
        format.html do
          redirect_to topic_path(@topic, anchor: helpers.dom_id(@comment)),
                      notice: t("flash.comments.update_success")
        end
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            @comment,
            partial: "topics/comment_form",
            locals: { topic: @topic, comment: @comment }
          ), status: :unprocessable_entity
        end
        format.html do
          redirect_to topic_path(@topic, anchor: helpers.dom_id(@comment)),
                      alert: @comment.errors.full_messages.to_sentence
        end
      end
    end
  end

  def destroy
    @comment.destroy

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove(helpers.dom_id(@comment)),
          turbo_stream.replace(
            "comments_count",
            partial: "topics/comments_count",
            locals: { topic: @topic }
          )
        ]
      end
      format.html do
        redirect_to topic_path(@topic), notice: t("flash.comments.destroy_success")
      end
    end
  end

  private

  def set_topic
    @topic = current_condominium.topics.find(params[:topic_id])
  end

  def set_comment
    @comment = @topic.comments.find(params[:id])
  end

  def require_comment_owner
    redirect_to topic_path(@topic), alert: t("flash.comments.not_authorized") unless @comment.user == current_user
  end

  def comment_params
    params.expect(comment: [ :content ])
  end
end
