class DashboardController < ApplicationController
  def index
    @tab = params[:tab] || 'topics'
    
    case @tab
    when 'announcements'
      @topics = current_condominium.topics.announcements.includes(:user).order(created_at: :desc)
      @new_topic = current_condominium.topics.new(topic_type: :announcement)
    when 'services'
      @services = current_condominium.service_listings.includes(:user).order(upvotes_count: :desc, created_at: :desc)
      @new_service = current_condominium.service_listings.new
    else # 'topics' (discussions)
      @topics = current_condominium.topics.discussions.includes(:user).order(upvotes_count: :desc, created_at: :desc)
      @new_topic = current_condominium.topics.new(topic_type: :discussion)
    end
  end
end
