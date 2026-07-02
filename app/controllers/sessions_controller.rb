class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create impersonate ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: t("flash.sessions.rate_limit") }

  def new
    @condominiums = Condominium.includes(:users).all
    @show_impersonation = Rails.env.development?
  end

  def create
    if user = User.authenticate_by(params.permit(:email_address, :password))
      start_new_session_for user
      redirect_to after_authentication_url
    else
      redirect_to new_session_path, alert: t("flash.sessions.auth_failure")
    end
  end

  def impersonate
    unless Rails.env.development?
      redirect_to new_session_path, alert: t("flash.sessions.impersonation_unavailable")
      return
    end

    user = User.find(params[:user_id])
    start_new_session_for user
    redirect_to root_path, notice: t("flash.sessions.impersonation_success", name: user.full_name, role: t("roles.#{user.role}"))
  end

  def destroy
    terminate_session
    redirect_to new_session_path, status: :see_other
  end
end
