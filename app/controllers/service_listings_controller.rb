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

  def vouch
    @service = current_condominium.service_listings.find(params[:id])
    vouch = @service.service_listing_upvotes.find_by(user: current_user)

    if vouch
      vouch.destroy
      message = t("flash.service_listings.vouch_removed", title: @service.title)
    else
      @service.service_listing_upvotes.create(user: current_user)
      message = t("flash.service_listings.vouch_success", title: @service.title)
    end

    redirect_to dashboard_path(tab: "services"), notice: message
  end

  private

  def service_params
    params.expect(service_listing: [ :title, :description, :contact_info, :category ])
  end
end
