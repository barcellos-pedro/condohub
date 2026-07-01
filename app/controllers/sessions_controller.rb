class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create impersonate ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: "Try again later." }

  def new
    @condominiums = Condominium.includes(:users).all
    @show_impersonation = Rails.env.development?
  end

  def create
    if user = User.authenticate_by(params.permit(:email_address, :password))
      start_new_session_for user
      redirect_to after_authentication_url
    else
      redirect_to new_session_path, alert: "Try another email address or password."
    end
  end

  def impersonate
    unless Rails.env.development?
      redirect_to new_session_path, alert: "Impersonation is only available in local development."
      return
    end

    user = User.find(params[:user_id])
    start_new_session_for user
    redirect_to root_path, notice: "Successfully impersonating #{user.full_name} (#{user.role.titleize})"
  end

  def destroy
    terminate_session
    redirect_to new_session_path, status: :see_other
  end
end
