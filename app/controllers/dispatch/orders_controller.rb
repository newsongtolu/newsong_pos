module Dispatch
  class OrdersController < ApplicationController
    before_action :authenticate_user!

    def index
      # Dispatch handles orders when they are ready or currently out for delivery
      @orders = Order.for_dispatch
                   .where(dispatch_status: ['ready_for_dispatch', 'out_for_delivery'])
                   .where.not(status: ["delivered", "completed", "cancelled"])
                   .order(created_at: :asc)
    end

    def update_status
      @order = Order.find(params[:id])
      new_status = params[:status]

      if new_status == "out_for_delivery"
        # Step 1: Update dispatch status so it stays on the board as out for delivery
        if @order.update(dispatch_status: 'out_for_delivery')
          redirect_to dispatch_orders_path, notice: "Order status updated to Out for Delivery."
        else
          redirect_to dispatch_orders_path, alert: "Could not update status."
        end
      elsif new_status == "delivered"
        # Step 2: Finalize order as delivered and clear it from the active delivery board
        if @order.update(status: 'delivered', dispatch_status: 'completed')
          redirect_to dispatch_orders_path, notice: "Order marked as Delivered and cleared from board."
        else
          redirect_to dispatch_orders_path, alert: "Could not update status."
        end
      else
        redirect_to dispatch_orders_path, alert: "Invalid status update."
      end
    end
  end
end