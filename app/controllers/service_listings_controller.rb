class ServiceListingsController < ApplicationController
  def create
    @service = current_condominium.service_listings.new(service_params)
    @service.user = current_user

    if @service.save
      redirect_to dashboard_path(tab: "services"), notice: t("flash.service_listings.create_success")
    else
      redirect_to dashboard_path(tab: "services"), alert: @service.errors.full_messages.to_sentence
    end
  end

  private

  def service_params
    params.expect(service_listing: [ :title, :description, :contact_info, :category ])
  end
end
