class RegistrationsController < ApplicationController
  allow_unauthenticated_access only: [ :new, :create ]
  before_action :redirect_if_authenticated
  before_action :set_invitation

  def new
    @user = User.new(email_address: @invitation.email_address)
  end

  def create
    @user = @invitation.condominium.users.new(registration_params)
    @user.email_address = @invitation.email_address
    @user.role = :resident

    ActiveRecord::Base.transaction do
      if @user.save
        @invitation.accept!
        start_new_session_for(@user)
        redirect_to dashboard_path, notice: t("flash.registrations.create_success", condo: @invitation.condominium.name)
      else
        render :new, status: :unprocessable_entity
      end
    end
  end

  private

  def redirect_if_authenticated
    redirect_to dashboard_path if authenticated?
  end

  def set_invitation
    @invitation = Invitation.find_by(token: params[:token])

    if @invitation.nil?
      redirect_to new_session_path, alert: t("flash.registrations.invalid_token")
    elsif @invitation.accepted?
      redirect_to new_session_path, alert: t("flash.registrations.already_accepted")
    elsif @invitation.expired?
      redirect_to new_session_path, alert: t("flash.registrations.expired_token")
    end
  end

  def registration_params
    params.expect(user: [ :first_name, :last_name, :password, :password_confirmation ])
  end
end
