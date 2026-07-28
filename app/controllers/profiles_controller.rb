class ProfilesController < ApplicationController
  before_action :require_authentication

  def edit
    @user = current_user
  end

  def update
    @user = current_user

    if password_change_requested? && !@user.authenticate(params[:user][:current_password])
      flash.now[:alert] = t("profiles.edit.wrong_password")
      render :edit, status: :unprocessable_entity
      return
    end

    if @user.update(user_params)
      redirect_to edit_profile_path, notice: t("profiles.edit.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.expect(user: [ :first_name, :last_name, :email_address, :password, :password_confirmation ])
  end

  def password_change_requested?
    params[:user][:password].present?
  end
end
