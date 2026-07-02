class ApplicationMailer < ActionMailer::Base
  default from: "from@example.com"
  layout "mailer"

  around_action :with_locale

  private

  def with_locale(&block)
    I18n.with_locale(params[:locale] || I18n.default_locale, &block)
  end
end
