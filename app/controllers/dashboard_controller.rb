class DashboardController < ApplicationController
  def index
    @tab = params[:tab] || "discussions"
    @query = params[:q].to_s.strip
    @category = params[:category]
    @page = (params[:page].to_i || 0)
    @per_page = 20

    case @tab
    when "announcements"
      topics_scope = current_condominium.topics.announcements.search(@query)
      @topics = topics_scope.includes(:user).order(created_at: :desc)
                            .limit(@per_page).offset(@page * @per_page)
      @has_more_topics = topics_scope.count > (@page + 1) * @per_page
      @new_topic = current_condominium.topics.new(topic_type: :announcement)
    when "services"
      services_scope = current_condominium.service_listings.search(@query).by_category(@category)
      @services = services_scope.includes(:user, :upvotes)
                                .order(upvotes_count: :desc, created_at: :desc)
                                .limit(@per_page).offset(@page * @per_page)
      @has_more_services = services_scope.count > (@page + 1) * @per_page
      @new_service = current_condominium.service_listings.new
    else # discussions
      topics_scope = current_condominium.topics.discussions.search(@query)
      @topics = topics_scope.includes(:user).order(upvotes_count: :desc, created_at: :desc)
                            .limit(@per_page).offset(@page * @per_page)
      @has_more_topics = topics_scope.count > (@page + 1) * @per_page
      @new_topic = current_condominium.topics.new(topic_type: :discussion)
    end

    @next_page = @page + 1
  end
end
