class UpvotesController < ApplicationController
  def create
    @topic = current_condominium.topics.find(params[:topic_id])
    upvote = @topic.upvotes.find_by(user: current_user)

    if upvote
      upvote.destroy
      message = 'Upvote removed.'
    else
      @topic.upvotes.create(user: current_user)
      message = 'Topic upvoted!'
    end

    redirect_back fallback_location: root_path, notice: message
  end
end
