class ErrorsController < ApplicationController
  skip_before_action :require_authentication

  def not_found
    render :not_found, status: :not_found
  end

  def internal_server_error
    render :internal_server_error, status: :internal_server_error
  end

  def unprocessable_entity
    render :unprocessable_entity, status: :unprocessable_entity
  end
end
