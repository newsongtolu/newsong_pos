module Kitchen
  class OrdersController < ApplicationController
    def index
      @orders = Order.where(kitchen_status: ['sent', 'preparing']).order(created_at: :asc)
    end

    def update
      @order = Order.find(params[:id])
      new_kitchen_status = params[:kitchen_status]

      update_attrs = { kitchen_status: new_kitchen_status }

      if new_kitchen_status == 'ready'
        # Combine and normalize fulfillment_type or service_mode safely
        raw_type = (@order.fulfillment_type.presence || @order.service_mode).to_s.downcase.strip

        # Keyword-based check prevents spacing/underscore mismatches
        is_floor = raw_type.include?('dine') || raw_type.include?('physical')

        if is_floor
          update_attrs[:floor_status] = 'ready_for_floor'
          Rails.logger.info ">>> KITCHEN: Order ##{@order.id} routed to FLOOR (#{raw_type})"
        else
          update_attrs[:dispatch_status] = 'ready_for_dispatch'
          Rails.logger.info ">>> KITCHEN: Order ##{@order.id} routed to DISPATCH (#{raw_type})"
        end
      end

      if @order.update(update_attrs)
        respond_to do |format|
          format.html { redirect_to kitchen_orders_path, notice: "Order status updated and routed!" }
          format.json { render json: { success: true, kitchen_status: @order.kitchen_status }, status: :ok }
        end
      else
        respond_to do |format|
          format.html { redirect_to kitchen_orders_path, alert: "Failed to update status." }
          format.json { render json: { success: false, errors: @order.errors.full_messages }, status: :unprocessable_entity }
        end
      end
    end
  end
end