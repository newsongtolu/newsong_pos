module Kitchen
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :require_kitchen!

    private

    def require_kitchen!
      unless ::Current.user&.kitchen? || ::Current.user&.super_admin?
        redirect_to root_path, alert: "Access denied. Kitchen clearance required."
      end
    end
  end
end