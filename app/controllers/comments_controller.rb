class CommentsController < ApplicationController
  def create
    @topic = current_condominium.topics.find(params[:topic_id])
    @comment = @topic.comments.new(comment_params)
    @comment.user = current_user

    if @comment.save
      redirect_to topic_path(@topic), notice: 'Comment posted successfully.'
    else
      redirect_to topic_path(@topic), alert: @comment.errors.full_messages.to_sentence
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:content)
  end
end
