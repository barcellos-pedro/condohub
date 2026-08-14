class UpvotesController < ApplicationController
  before_action :require_authentication
  before_action :set_upvotable

  def create
    result = Upvote.toggle(user: current_user, upvotable: @upvotable)
    redirect_back fallback_location: fallback_path, notice: success_message(result)
  end

  private

  def set_upvotable
    @upvotable = if params[:topic_id] && !params[:comment_id]
      current_condominium.topics.find(params[:topic_id])
    elsif params[:service_listing_id]
      current_condominium.service_listings.find(params[:service_listing_id])
    elsif params[:comment_id]
      Comment.joins(:topic)
             .where(topics: { condominium_id: current_condominium.id })
             .find(params[:comment_id])
    end
  end

  def success_message(action)
    case @upvotable
    when Topic
      t("flash.upvotes.#{action}")
    when ServiceListing
      t("flash.service_listings.vouch_#{action}", title: @upvotable.title)
    when Comment
      t("flash.comments.upvote_#{action}")
    end
  end

  def fallback_path
    case @upvotable
    when Topic
      dashboard_path
    when ServiceListing
      dashboard_path(tab: "services")
    when Comment
      topic_path(@upvotable.topic, anchor: helpers.dom_id(@upvotable))
    end
  end
end
