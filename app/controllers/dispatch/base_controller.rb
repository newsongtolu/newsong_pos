module Dispatch
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :verify_dispatch_access!

    private

    def verify_dispatch_access!
      user_role = current_user&.role.to_s.downcase
      allowed_roles = %w[dispatch admin super_admin]
      
      unless allowed_roles.include?(user_role)
        redirect_to root_path, alert: "Access restricted to dispatch personnel."
      end
    end
  end
end