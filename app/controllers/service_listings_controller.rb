class ServiceListingsController < ApplicationController
  before_action :set_service_listing, only: [ :edit, :update, :destroy ]
  before_action :require_owner, only: [ :edit, :update, :destroy ]

  def create
    @service = current_condominium.service_listings.new(service_params)
    @service.user = current_user

    if @service.save
      redirect_to dashboard_path(tab: "services"), notice: t("flash.service_listings.create_success")
    else
      redirect_to dashboard_path(tab: "services"), alert: @service.errors.full_messages.to_sentence
    end
  end

  def edit
  end

  def update
    if @service_listing.update(service_params)
      redirect_to dashboard_path(tab: "services"), notice: t("flash.service_listings.update_success")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @service_listing.destroy
    redirect_to dashboard_path(tab: "services"), notice: t("flash.service_listings.destroy_success")
  end

  private

  def set_service_listing
    @service_listing = current_condominium.service_listings.find(params[:id])
  end

  def require_owner
    unless @service_listing.editable_by?(current_user)
      redirect_to dashboard_path(tab: "services"), alert: t("flash.service_listings.not_authorized")
    end
  end

  def service_params
    params.expect(service_listing: [ :title, :description, :contact_info, :category ])
  end
end
