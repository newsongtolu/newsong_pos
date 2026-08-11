module Admin
  class OrdersController < ApplicationController
    before_action :set_order, only: [:update, :destroy]

    def index
      @orders = Order.all.order(created_at: :desc)
    end

    def update
      if @order.update(order_params)
        redirect_to admin_orders_path, notice: "Order status successfully updated."
      else
        @orders = Order.all.order(created_at: :desc)
        render :index, status: :unprocessable_entity
      end
    end

    def destroy
      @order.destroy
      redirect_to admin_orders_path, notice: "Order cancelled and removed from queue."
    end

    private

    def set_order
      @order = Order.find(params[:id])
    end

    def order_params
      params.require(:order).permit(:status, :payment_status)
    end
  end
end