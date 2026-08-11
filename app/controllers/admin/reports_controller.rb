module Admin
  class ReportsController < ApplicationController
    def index
      @total_revenue = Order.sum(:total_amount) rescue 0
      @total_orders = Order.count rescue 0
      @cash_collections = Order.where(payment_method: 'cash').sum(:total_amount) rescue 0
    end
  end
end