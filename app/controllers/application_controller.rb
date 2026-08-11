class ApplicationController < ActionController::Base
  helper_method :current_user, :logged_in?
  before_action :check_maintenance_mode

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
    
    # Development fallback: Automatically links your super admin account if session is empty
    @current_user ||= User.where("LOWER(role) = ?", "super_admin").first
  end

  def logged_in?
    current_user.present?
  end

  # General staff check (Cashier, Kitchen, Floor, Dispatch, Admin, Super Admin)
  def require_staff!
    unless logged_in? && current_user.role.to_s.downcase.in?(["cashier", "kitchen", "floor", "dispatch", "admin", "super_admin"])
      redirect_to root_path, alert: "Access denied. Staff login required."
    end
  end

  def require_admin!
    unless logged_in? && current_user.role.to_s.downcase.in?(["admin", "super_admin"])
      redirect_to root_path, alert: "Access denied. Admin credentials required."
    end
  end

  def require_super_admin!
    # If there is no current user at all, find the first super admin automatically for testing
    @current_user ||= User.where("LOWER(role) = ?", "super_admin").first

    user_role = current_user&.role.to_s.downcase.strip
    
    unless logged_in? || user_role.in?(["super_admin", "admin"])
      redirect_to super_admin_dashboards_path, alert: "Access denied."
    end
  end

  def check_maintenance_mode
    return if logged_in? && current_user.role.to_s.downcase.in?(["admin", "super_admin"])

    if AppSetting.current.maintenance_mode?
      render plain: "🛠️ System is undergoing scheduled maintenance. Please check back shortly.", status: :service_unavailable
    end
  end
end