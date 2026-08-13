class CondominiumsController < ApplicationController
  before_action :require_admin

  def show
    @total_residents = current_condominium.users.count

    @active_residents = current_condominium.users
      .left_joins(:topics, :comments)
      .where("topics.created_at > ? OR comments.created_at > ?", 30.days.ago, 30.days.ago)
      .distinct
      .count

    @topics_this_month = current_condominium.topics
      .where(created_at: Time.current.beginning_of_month..)
      .count

    @top_services = current_condominium.service_listings
      .order(upvotes_count: :desc)
      .limit(5)

    @recent_announcements = current_condominium.topics
      .announcements
      .order(created_at: :desc)
      .limit(5)
  end

  def edit
    @condominium = current_condominium
  end

  def update
    @condominium = current_condominium
    if @condominium.update(condominium_params)
      redirect_to dashboard_path, notice: t(".success")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def condominium_params
    params.expect(condominium: [ :name, :address, :whatsapp_group_link ])
  end

  def require_admin
    redirect_to dashboard_path, alert: t("condominiums.unauthorized") unless current_user.admin?
  end
end
