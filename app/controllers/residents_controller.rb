class ResidentsController < ApplicationController
  before_action :require_authentication

  def show
    @resident = current_condominium.users.find(params[:id])
    @recent_topics = @resident.topics.order(created_at: :desc).limit(10)
    @recent_comments = @resident.comments.order(created_at: :desc).limit(10)
    @services = @resident.service_listings.order(created_at: :desc).limit(10)
  rescue ActiveRecord::RecordNotFound
    redirect_to dashboard_path, alert: I18n.t("not_found")
  end
end
