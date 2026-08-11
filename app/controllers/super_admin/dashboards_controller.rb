module SuperAdmin
  class DashboardsController < ApplicationController
    def index
      @total_system_revenue = Order.sum(:total_amount) rescue 0
      @total_users = User.count rescue 0
      @active_stations = 4
    end
  end
end