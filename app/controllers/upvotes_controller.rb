class UpvotesController < ApplicationController
  def create
    @topic = current_condominium.topics.find(params[:topic_id])
    upvote = @topic.upvotes.find_by(user: current_user)

    if upvote
      upvote.destroy
      message = t("flash.upvotes.removed")
    else
      @topic.upvotes.create(user: current_user)
      message = t("flash.upvotes.success")
    end

    redirect_back fallback_location: dashboard_path, notice: message
  end
end
