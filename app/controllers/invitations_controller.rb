class InvitationsController < ApplicationController
  before_action :require_admin

  def new
    @invitation = current_condominium.invitations.new
  end

  def create
    @invitation = current_condominium.invitations.new(invitation_params)
    @invitation.invited_by = current_user

    if @invitation.save
      InvitationMailer.invite(@invitation, locale: I18n.locale).deliver_later
      redirect_to invitation_path(@invitation), notice: t("flash.invitations.create_success")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @invitation = current_condominium.invitations.find(params[:id])
  end

  private

  def require_admin
    redirect_to dashboard_path, alert: t("condominiums.unauthorized") unless current_user.admin?
  end

  def invitation_params
    params.expect(invitation: [ :email_address ])
  end
end
