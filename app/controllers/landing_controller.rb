class LandingController < ApplicationController
  allow_unauthenticated_access
  layout "landing"

  def index
    redirect_to dashboard_path if authenticated?
  end
end
