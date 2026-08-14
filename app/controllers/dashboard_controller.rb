class DashboardController < ApplicationController
  def index
    @tab = params[:tab] || "discussions"
    @query = params[:q].to_s.strip
    @category = params[:category]
    @sort = params[:sort]
    @page = params[:page].to_i
    @per_page = 20

    result = Dashboard.query(
      condominium: current_condominium,
      tab: @tab,
      search: @query,
      category: @category,
      sort: @sort,
      page: @page,
      per_page: @per_page
    )

    case @tab
    when "services"
      @services = result.items
      @has_more_services = result.has_more
      @new_service = result.new_record
    else
      @topics = result.items
      @has_more_topics = result.has_more
      @new_topic = result.new_record
    end

    @next_page = @page + 1
  end
end
