class CondominiumsController < ApplicationController
  before_action :require_admin

  def edit
    @condominium = current_condominium
  end

  def update
    @condominium = current_condominium
    if @condominium.update(condominium_params)
      redirect_to dashboard_path, notice: t(".success")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def condominium_params
    params.expect(condominium: [ :name, :address, :whatsapp_group_link ])
  end

  def require_admin
    redirect_to dashboard_path, alert: t(".unauthorized") unless current_user.admin?
  end
end
