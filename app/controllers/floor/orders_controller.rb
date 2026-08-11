module Floor
  class OrdersController < ApplicationController
    def index
      # Floor strictly handles Dining and Physical Takeaway when marked ready by the kitchen
      @orders = Order.for_floor
                     .where(floor_status: 'ready_for_floor')
                     .where.not(status: ["served", "completed", "cancelled"])
                     .order(created_at: :asc)
    end

    def update_status
      @order = Order.find(params[:id])
      new_status = params[:status] || "served"

      # Update both general status and close out floor status so it clears the screen queue
      if @order.update(status: new_status, floor_status: 'served')
        redirect_to floor_orders_path, notice: "Order marked as served."
      else
        redirect_to floor_orders_path, alert: "Could not update status."
      end
    end
  end
end