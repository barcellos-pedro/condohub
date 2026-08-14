class WaitlistController < ApplicationController
  allow_unauthenticated_access only: %i[ create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to root_path, alert: t("flash.waitlist.rate_limit") }

  def create
    email = params[:email_address].to_s.strip.downcase
    @waitlist_entry = WaitlistEntry.find_or_initialize_by(email_address: email)
    @waitlist_entry.locale ||= I18n.locale.to_s

    if @waitlist_entry.persisted? || @waitlist_entry.save
      render_success
    else
      render_error
    end
  end

  private

  def form_id
    params[:form_id].presence || "request_access"
  end

  def render_success
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace(form_id, partial: "landing/request_access_success") }
      format.html { redirect_to root_path, notice: t("landing.index.request_access_success") }
    end
  end

  def render_error
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(form_id, partial: "landing/request_access", locals: { form_id: form_id, email_address: params[:email_address] }), status: :unprocessable_entity
      end
      format.html { redirect_to root_path, alert: t("flash.waitlist.invalid_email") }
    end
  end
end
