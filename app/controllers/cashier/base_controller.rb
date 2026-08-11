module Cashier
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :require_cashier!

    private

    def require_cashier!
      unless current_user&.cashier? || current_user&.super_admin?
        redirect_to root_path, alert: "Access denied. Cashier clearance required."
      end
    end
  end
end