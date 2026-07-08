class UpvotesController < ApplicationController
  def create
    upvotable = if params[:topic_id]
                  current_condominium.topics.find(params[:topic_id])
    else
                  current_condominium.service_listings.find(params[:service_listing_id])
    end

    upvote = upvotable.upvotes.find_by(user: current_user)

    if upvote
      upvote.destroy
      message = if upvotable.is_a?(Topic)
                  t("flash.upvotes.removed")
      else
                  t("flash.service_listings.vouch_removed", title: upvotable.title)
      end
    else
      upvotable.upvotes.create!(user: current_user)
      message = if upvotable.is_a?(Topic)
                  t("flash.upvotes.success")
      else
                  t("flash.service_listings.vouch_success", title: upvotable.title)
      end
    end

    fallback = upvotable.is_a?(Topic) ? dashboard_path : dashboard_path(tab: "services")
    redirect_back fallback_location: fallback, notice: message
  end
end
