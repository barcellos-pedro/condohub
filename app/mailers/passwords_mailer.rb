class PasswordsMailer < ApplicationMailer
  def reset(user, locale: I18n.locale)
    @user = user
    params[:locale] = locale
    mail subject: t(".subject"), to: user.email_address
  end
end
