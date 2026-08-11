module Dispatch
  class OrdersController < BaseController
    def index
      @orders = Order.where(status: ["ready", "dispatched"]).order(created_at: :asc)
    end

    def update
      @order = Order.find(params[:id])
      new_status = params[:status]
      
      if @order.update(status: new_status)
        redirect_to dispatch_orders_path, notice: "Order ##{@order.id} status updated to #{new_status.titleize}!"
      else
        redirect_to dispatch_orders_path, alert: "Could not update order status."
      end
    end
  end
end