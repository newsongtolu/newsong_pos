module Dispatch
  class OrdersController < ApplicationController
    def index
      # Dispatch strictly handles Online Takeaway and Home Delivery when marked ready by the kitchen
      @orders = Order.for_dispatch
                     .where(dispatch_status: 'ready_for_dispatch')
                     .where.not(status: ["delivered", "completed", "cancelled"])
                     .order(created_at: :asc)
    end

    def update_status
      @order = Order.find(params[:id])
      new_status = params[:status]
      
      update_attrs = { status: new_status }
      # If marked delivered, update dispatch status to clear it from the active delivery board
      update_attrs[:dispatch_status] = 'completed' if new_status == "delivered"

      if @order.update(update_attrs)
        status_label = new_status == "delivered" ? "Delivered" : "Out for Delivery"
        redirect_to dispatch_orders_path, notice: "Order status updated to #{status_label}."
      else
        redirect_to dispatch_orders_path, alert: "Could not update status."
      end
    end
  end
end