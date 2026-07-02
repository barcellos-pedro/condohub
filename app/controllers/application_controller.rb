class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :set_locale

  helper_method :current_user, :current_condominium

  private

  def current_user
    Current.user
  end

  def current_condominium
    current_user&.condominium
  end

  def set_locale
    locale = params[:locale] || cookies[:locale] || extract_locale_from_accept_language || I18n.default_locale
    locale = I18n.default_locale unless locale.to_s.in?(I18n.available_locales.map(&:to_s))
    I18n.locale = locale
    cookies.permanent[:locale] = locale
  end

  def extract_locale_from_accept_language
    accepted = request.env["HTTP_ACCEPT_LANGUAGE"]&.scan(/^[a-z]{2}(?:-[A-Z]{2})?/)&.first
    accepted&.to_sym if accepted&.to_sym&.in?(I18n.available_locales)
  end

  def default_url_options
    { locale: I18n.locale }
  end
end
