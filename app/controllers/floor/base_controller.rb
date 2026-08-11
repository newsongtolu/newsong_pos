module Floor
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :require_floor!

    private

    def require_floor!
      unless current_user&.floor? || current_user&.super_admin?
        redirect_to root_path, alert: "Access denied. Floor staff clearance required."
      end
    end
  end
end