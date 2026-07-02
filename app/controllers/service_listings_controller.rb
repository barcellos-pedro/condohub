class ServiceListingsController < ApplicationController
  def create
    @service = current_condominium.service_listings.new(service_params)
    @service.user = current_user

    if @service.save
      redirect_to root_path(tab: 'services'), notice: t("flash.service_listings.create_success")
    else
      redirect_to root_path(tab: 'services'), alert: @service.errors.full_messages.to_sentence
    end
  end

  def vouch
    @service = current_condominium.service_listings.find(params[:id])
    @service.increment!(:upvotes_count)
    redirect_to root_path(tab: 'services'), notice: t("flash.service_listings.vouch_success", title: @service.title)
  end

  private

  def service_params
    params.require(:service_listing).permit(:title, :description, :contact_info, :category)
  end
end
