module Cashier
  class OrdersController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [:create, :append_item]

    def index
      @orders = Order.where(status: ["Pending", nil])
      
      if params[:search].present?
        search_term = "%#{params[:search]}%"
        @orders = @orders.where("customer_name LIKE ? OR phone LIKE ?", search_term, search_term)
      end
      
      @orders = @orders.order(created_at: :desc)
    end

    def create
      safe_params = params[:order].present? ? order_params : direct_order_params
      @order = Order.new(safe_params)
      @order.status ||= "Pending"
      @order.added_by ||= params[:added_by].presence || "inputed by customer"
      
      if (@order.grand_total.nil? || @order.grand_total == 0) && @order.order_items.any?
        @order.grand_total = @order.order_items.sum { |item| item.price.to_f * item.quantity.to_f }
      end
      
      if @order.save
        create_payment_records(@order, params[:order] || params)
        Rails.logger.info ">>> SUCCESS: Order ##{@order.id} saved with #{@order.order_items.count} items and total ₦#{@order.grand_total}."
        render json: { success: true, order_id: @order.id }, status: :ok
      else
        Rails.logger.error ">>> FAILED TO SAVE ORDER: #{@order.errors.full_messages}"
        render json: { success: false, errors: @order.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def edit
      @order = Order.find(params[:id])
      session[:active_order_id] = @order.id
    end

    def add_items
      @order = Order.find(params[:id])
    end

    def append_item
      @order = Order.find_by(id: params[:id])
      unless @order
        render json: { success: false, error: "Order not found" }, status: :not_found and return
      end
      
      json_body = {}
      begin
        json_body = JSON.parse(request.raw_post) rescue {} if request.raw_post.present?
      rescue => e
        Rails.logger.error ">>> JSON parse error in append_item: #{e.message}"
      end
      
      combined_params = params.to_unsafe_h.deep_merge(json_body.is_a?(Hash) ? json_body : {})
      o_params = combined_params[:order].is_a?(Hash) ? combined_params[:order] : combined_params
      
      # Process and build the newly appended items onto the order
      process_items_for_order(@order, o_params, combined_params)
      
      active_items = @order.order_items.reject { |item| item.marked_for_destruction? }
      calculated_total = active_items.sum { |item| item.price.to_f * item.quantity.to_f }
      supplied_total = (o_params[:grand_total] || combined_params[:grand_total] || 0).to_s.gsub(/[^\d.]/, '').to_f
      final_total = supplied_total > 0 ? supplied_total : calculated_total
      
      # Pass any new payment method down to the model virtual attribute before saving
      @order.new_payment_method = o_params[:new_payment_method].presence || o_params[:payment_method].presence

      if @order.update(grand_total: final_total)
        # Model callback 'handle_payments' automatically calculates the difference and logs the new payment row cleanly
        Rails.logger.info ">>> SUCCESS: Order ##{@order.id} successfully updated with appended items. New total: ₦#{@order.grand_total}"
        respond_to do |format|
          format.html { redirect_to edit_cashier_order_path(@order), notice: "New items added successfully." }
          format.json { render json: { success: true, message: 'Order successfully updated with new items!', order_id: @order.id }, status: :ok }
        end
      else
        Rails.logger.error ">>> FAILED TO UPDATE ORDER APPEND: #{@order.errors.full_messages}"
        respond_to do |format|
          format.html { render :add_items, status: :unprocessable_entity }
          format.json { render json: { success: false, errors: @order.errors.full_messages }, status: :unprocessable_entity }
        end
      end
    end

    def update
      @order = Order.find(params[:id])
      sub_params = params[:order] || {}
      
      # Assign the virtual payment method so the model callback can pick it up
      @order.new_payment_method = sub_params[:new_payment_method].presence || sub_params[:payment_method].presence

      if @order.update(order_params)
        active_items = @order.order_items.reject { |item| item.marked_for_destruction? rescue false }
        new_total = active_items.sum { |item| item.price.to_f * item.quantity.to_f }
        
        # Updating grand_total triggers the model's safe payment-handling callback automatically
        @order.update(grand_total: new_total)
        
        Rails.logger.info ">>> SUCCESS: Order ##{@order.id} updated. New total: ₦#{new_total}"
        redirect_to cashier_orders_path, notice: "Order updated successfully."
      else
        Rails.logger.error ">>> FAILED TO UPDATE ORDER: ##{@order.id}"
        render :edit, status: :unprocessable_entity
      end
    end

    def verify_payment
      @order = Order.find(params[:id])
      
      if @order.update(status: "Verified", kitchen_status: "sent")
        Rails.logger.info ">>> SUCCESS: Order ##{@order.id} verified and routed to kitchen."
        redirect_to cashier_orders_path, notice: "Order verified successfully and sent to kitchen!"
      else
        redirect_to cashier_orders_path, alert: "Could not verify order."
      end
    end

    private

    def create_payment_records(order, data_source, custom_amount = nil)
      method_key = data_source[:new_payment_method].presence || data_source[:payment_method].presence || order.payment_method.presence || "cash"
      method_key = method_key.to_s.downcase.strip
      amount_to_log = custom_amount.present? ? custom_amount.to_f : order.grand_total.to_f
      if method_key == "split" || data_source[:split_method_1].present?
        s_method_1 = (data_source[:split_method_1] || "cash").to_s.downcase.strip
        s_amount_1 = (data_source[:split_amount_1] || 0).to_f
        s_method_2 = (data_source[:split_method_2] || "").to_s.downcase.strip
        s_amount_2 = (data_source[:split_amount_2] || 0).to_f
        order.payments.create(payment_method: s_method_1, amount: s_amount_1) if s_amount_1 > 0
        order.payments.create(payment_method: s_method_2, amount: s_amount_2) if s_method_2.present? && s_amount_2 > 0
      else
        normalized_method = case method_key
                            when /transfer/ then "transfer"
                            when /pos/ then "pos"
                            when /split/ then "split"
                            else "cash"
                            end
        order.payments.create(payment_method: normalized_method, amount: amount_to_log) if amount_to_log > 0
      end
    end

    def process_items_for_order(order, o_params, combined_params)
      containers = o_params[:containers] || combined_params[:containers]
      if containers.present?
        containers_list = containers.is_a?(Hash) ? containers.values : containers
        containers_list.each do |container|
          next unless container.is_a?(Hash) || container.is_a?(ActionController::Parameters)
          
          pkg_name = container[:packaging] || container["packaging"] || "Container"
          pkg_price = (container[:packagingPrice] || container["packagingPrice"] || 0).to_s.gsub(/[^\d.]/, '').to_f
          if pkg_price > 0
            order.order_items.build(name: "#{pkg_name} Fee", price: pkg_price, quantity: 1, is_appended: true)
          end
          
          items_hash_or_array = container[:items] || container["items"]
          if items_hash_or_array.present?
            items_enum = items_hash_or_array.is_a?(Hash) ? items_hash_or_array.values : items_hash_or_array
            items_enum.each do |item_attrs|
              next unless item_attrs.is_a?(Hash) || item_attrs.is_a?(ActionController::Parameters)
              name = item_attrs[:name] || item_attrs["name"]
              price = (item_attrs[:price] || item_attrs["price"] || 0).to_s.gsub(/[^\d.]/, '').to_f
              qty = (item_attrs[:qty] || item_attrs[:quantity] || item_attrs["qty"] || item_attrs["quantity"] || 1).to_i
              if name.present? && qty > 0
                order.order_items.build(name: name, price: price, quantity: qty, is_appended: true)
              end
            end
          end
        end
      end
      dine_in_items = o_params[:dine_in_items] || combined_params[:dine_in_items]
      if dine_in_items.present?
        items_enum = dine_in_items.is_a?(Hash) ? dine_in_items.values : dine_in_items
        items_enum.each do |item_attrs|
          next unless item_attrs.is_a?(Hash) || item_attrs.is_a?(ActionController::Parameters)
          name = item_attrs[:name] || item_attrs["name"]
          price = (item_attrs[:price] || item_attrs["price"] || 0).to_s.gsub(/[^\d.]/, '').to_f
          qty = (item_attrs[:qty] || item_attrs[:quantity] || item_attrs["qty"] || item_attrs["quantity"] || 1).to_i
          if name.present? && qty > 0
            order.order_items.build(name: name, price: price, quantity: qty, is_appended: true)
          end
        end
      end
      raw_items = o_params[:order_items_attributes] || o_params[:order_items] || o_params[:items] || o_params[:cart_items] || 
                  combined_params[:order_items_attributes] || combined_params[:order_items] || combined_params[:items] || combined_params[:cart_items]
      if raw_items.present?
        items_enum = raw_items.is_a?(Hash) ? raw_items.values : raw_items
        if items_enum.is_a?(Array)
          items_enum.each do |item_attrs|
            next unless item_attrs.is_a?(Hash) || item_attrs.is_a?(ActionController::Parameters)
            next if item_attrs[:_destroy].to_s == "1" || item_attrs["_destroy"].to_s == "1"
            name = item_attrs[:name] || item_attrs[:item_name] || item_attrs["name"] || item_attrs["item_name"]
            price = (item_attrs[:price] || item_attrs["price"] || 0).to_s.gsub(/[^\d.]/, '').to_f
            quantity = (item_attrs[:quantity] || item_attrs[:qty] || item_attrs["quantity"] || item_attrs["qty"] || 1).to_i
            if name.present?
              order.order_items.build(name: name, price: price, quantity: quantity, is_appended: true)
            end
          end
        end
      end
    end

    def order_params
      params.require(:order).permit(
        :customer_name, 
        :phone, 
        :payment_method, 
        :new_payment_method,
        :grand_total,
        :service_mode,      
        :fulfillment_type,   
        :split_method_1, 
        :split_amount_1, 
        :split_method_2, 
        :split_amount_2,
        order_items_attributes: [:id, :menu_item_id, :name, :price, :quantity, :_destroy, :is_appended]
      )
    end

    def direct_order_params
      params.permit(
        :customer_name,
        :phone,
        :email,
        :payment_method,
        :new_payment_method,
        :grand_total,
        :service_mode,
        :fulfillment_type,
        :notes,
        :added_by,
        :split_method_1,
        :split_amount_1,
        :split_method_2,
        :split_amount_2,
        order_items_attributes: [:id, :menu_item_id, :name, :price, :quantity, :_destroy, :is_appended],
        containers_attributes: [:id, :name, :_destroy]
      )
    end

    def order_item_params
      params.require(:order_item).permit(:menu_item_id, :name, :price, :quantity, :is_appended)
    end
  end
end