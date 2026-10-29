class InvitationMailer < ApplicationMailer
  def invite(invitation, locale: I18n.locale)
    @invitation = invitation
    @condominium = invitation.condominium
    params[:locale] = locale
    mail subject: t(".subject", condo: @condominium.name), to: invitation.email_address
  end
end
