class OrdersController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create, :append_item]

  def index
    @orders = Order.order(created_at: :desc)
  end

  def create
    json_body = {}
    begin
      if request.raw_post.present?
        json_body = JSON.parse(request.raw_post) rescue {}
      end
    rescue => e
      Rails.logger.error ">>> JSON parse error: #{e.message}"
    end

    combined_params = params.to_unsafe_h.deep_merge(json_body.is_a?(Hash) ? json_body : {})
    o_params = combined_params[:order].is_a?(Hash) ? combined_params[:order] : combined_params
    Rails.logger.info ">>> FINAL COMBINED PARAMS POOL: #{combined_params.inspect}"

    existing_id = o_params[:existing_order_id] || combined_params[:existing_order_id]
    if existing_id.present?
      @order = Order.find_by(id: existing_id)
      if @order
        process_items_for_order(@order, o_params, combined_params, true)
        new_total = @order.order_items.sum { |i| i.price.to_f * i.quantity.to_f }
        @order.update(grand_total: new_total)
        render json: { success: true, order_id: @order.id }, status: :ok and return
      end
    end

    customer_name = o_params[:customer_name] || combined_params[:customer_name] || "Self-Service Customer"
    phone = o_params[:phone] || o_params[:phone_number] || combined_params[:phone] || combined_params[:phone_number]
    email = o_params[:email] || combined_params[:email]
    payment_method = o_params[:payment_method] || combined_params[:payment_method] || "Cash"
    service_mode = o_params[:service_mode] || combined_params[:service_mode] || "dine_in"
    fulfillment_type = o_params[:fulfillment_type] || combined_params[:fulfillment_type] || "Pickup"
    notes = o_params[:notes] || combined_params[:notes]
    added_by = o_params[:added_by] || combined_params[:added_by] || "customer"

    @order = Order.new(
      customer_name: customer_name,
      phone: phone.presence,
      email: email.presence,
      payment_method: payment_method,
      service_mode: service_mode,
      fulfillment_type: fulfillment_type,
      notes: notes,
      added_by: added_by,
      status: "Pending"
    )

    process_items_for_order(@order, o_params, combined_params, false)

    # Check if any ordered items are out of stock
    if @out_of_stock_error.present?
      render json: { success: false, errors: [@out_of_stock_error] }, status: :unprocessable_entity and return
    end

    calculated_total = @order.order_items.sum { |item| item.price.to_f * item.quantity.to_f }
    supplied_total = (o_params[:grand_total] || combined_params[:grand_total] || 0).to_s.gsub(/[^\d.]/, '').to_f
    final_total = supplied_total > 0 ? supplied_total : calculated_total
    @order.grand_total = final_total

    if @order.save
      # Log initial payment record for disaggregation tracking
      if @order.respond_to?(:payments) && final_total > 0
        normalized_method = payment_method.to_s.downcase.strip
        normalized_method = "pos" if normalized_method.include?("pos")
        normalized_method = "transfer" if normalized_method.include?("transfer")
        @order.payments.create(payment_method: normalized_method, amount: final_total)
      end

      Rails.logger.info ">>> SUCCESS: Order ##{@order.id} saved with phone: #{@order.phone} and #{@order.order_items.count} items."
      render json: { success: true, order_id: @order.id, message: "Order placed successfully!" }, status: :ok
    else
      Rails.logger.error ">>> FAILED TO SAVE ORDER: #{@order.errors.full_messages}"
      render json: { success: false, errors: @order.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def append_item
    @order = Order.find_by(id: params[:id])
    unless @order
      render json: { success: false, error: "Order not found" }, status: :not_found and return
    end

    json_body = {}
    begin
      if request.raw_post.present?
        json_body = JSON.parse(request.raw_post) rescue {}
      end
    rescue => e
      Rails.logger.error ">>> JSON parse error in append_item: #{e.message}"
    end

    combined_params = params.to_unsafe_h.deep_merge(json_body.is_a?(Hash) ? json_body : {})
    o_params = combined_params[:order].is_a?(Hash) ? combined_params[:order] : combined_params

    old_total = @order.grand_total.to_f
    process_items_for_order(@order, o_params, combined_params, true)

    if @out_of_stock_error.present?
      render json: { success: false, errors: [@out_of_stock_error] }, status: :unprocessable_entity and return
    end

    calculated_total = @order.order_items.sum { |item| item.price.to_f * item.quantity.to_f }
    supplied_total = (o_params[:grand_total] || combined_params[:grand_total] || 0).to_s.gsub(/[^\d.]/, '').to_f
    final_total = supplied_total > 0 ? supplied_total : calculated_total
    
    added_amount = final_total - old_total
    new_payment_method = o_params[:new_payment_method].presence || o_params[:payment_method].presence || "cash"

    if @order.update(grand_total: final_total)
      # Create payment record for newly appended items so disaggregation reflects POS/Transfer correctly
      if added_amount > 0 && @order.respond_to?(:payments)
        normalized_method = new_payment_method.to_s.downcase.strip
        normalized_method = "pos" if normalized_method.include?("pos")
        normalized_method = "transfer" if normalized_method.include?("transfer")
        @order.payments.create(payment_method: normalized_method, amount: added_amount)
      end

      Rails.logger.info ">>> SUCCESS: Order ##{@order.id} successfully updated with appended items. Added ₦#{added_amount} via #{new_payment_method}. New total: #{@order.grand_total}"
      render json: { success: true, message: 'Order successfully updated with new items!', order_id: @order.id }, status: :ok
    else
      Rails.logger.error ">>> FAILED TO UPDATE ORDER APPEND: #{@order.errors.full_messages}"
      render json: { success: false, errors: @order.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def edit
    @order = Order.find(params[:id])
  end

  def update
    @order = Order.find(params[:id])
    json_body = {}
    begin
      if request.raw_post.present?
        json_body = JSON.parse(request.raw_post) rescue {}
      end
    rescue => e
      Rails.logger.error ">>> JSON parse error in update: #{e.message}"
    end

    combined_params = params.to_unsafe_h.deep_merge(json_body.is_a?(Hash) ? json_body : {})
    o_params = combined_params[:order].is_a?(Hash) ? combined_params[:order] : combined_params

    process_items_for_order(@order, o_params, combined_params, true)

    if @order.update(order_params)
      calculated_total = @order.order_items.sum { |item| item.price.to_f * item.quantity.to_f }
      supplied_total = (o_params[:grand_total] || combined_params[:grand_total] || 0).to_s.gsub(/[^\d.]/, '').to_f
      final_total = supplied_total > 0 ? supplied_total : calculated_total
      @order.update(grand_total: final_total) if final_total > 0

      if request.format.json? || params[:ajax].present?
        render json: { success: true, message: "Order updated successfully!", order_id: @order.id }, status: :ok
      else
        redirect_to cashier_orders_path, notice: "Order updated successfully!"
      end
    else
      if request.format.json? || params[:ajax].present?
        render json: { success: false, errors: @order.errors.full_messages }, status: :unprocessable_entity
      else
        render :edit, status: :unprocessable_entity
      end
    end
  end

  def verify_payment
    @order = Order.find(params[:id])
    if @order.update(status: "Verified")
      redirect_to cashier_orders_path, notice: "Order verified successfully!"
    else
      redirect_to cashier_orders_path, alert: "Could not verify order."
    end
  end

  private

  def item_out_of_stock?(item_name)
    return false unless item_name.present?
    menu_item = MenuItem.find_by("lower(name) = ?", item_name.strip.downcase)
    return false unless menu_item

    if menu_item.respond_to?(:out_of_stock?) && menu_item.out_of_stock?
      true
    elsif menu_item.respond_to?(:status) && menu_item.status.to_s.downcase.include?("out")
      true
    else
      false
    end
  end

  def process_items_for_order(order, o_params, combined_params, is_appended = false)
    @out_of_stock_error = nil

    containers = o_params[:containers] || combined_params[:containers]
    if containers.present?
      containers_list = containers.is_a?(Hash) ? containers.values : containers
      containers_list.each do |container|
        next unless container.is_a?(Hash) || container.is_a?(ActionController::Parameters)
        
        pkg_name = container[:packaging] || container["packaging"] || "Container"
        pkg_price = (container[:packagingPrice] || container["packagingPrice"] || 0).to_s.gsub(/[^\d.]/, '').to_f
        if pkg_price > 0
          order.order_items.build(name: "#{pkg_name} Fee", price: pkg_price, quantity: 1, is_appended: is_appended)
        end
        
        items_hash_or_array = container[:items] || container["items"]
        if items_hash_or_array.present?
          items_enum = items_hash_or_array.is_a?(Hash) ? items_hash_or_array.values : items_hash_or_array
          items_enum.each do |item_attrs|
            next unless item_attrs.is_a?(Hash) || item_attrs.is_a?(ActionController::Parameters)
            item_name = item_attrs[:name] || item_attrs["name"]
            item_price = (item_attrs[:price] || item_attrs["price"] || 0).to_s.gsub(/[^\d.]/, '').to_f
            item_qty = (item_attrs[:qty] || item_attrs[:quantity] || item_attrs["qty"] || item_attrs["quantity"] || 1).to_i
            
            if item_name.present? && item_qty > 0
              if item_out_of_stock?(item_name)
                @out_of_stock_error = "#{item_name} is currently out of stock."
                next
              end
              order.order_items.build(name: item_name, price: item_price, quantity: item_qty, is_appended: is_appended)
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
        item_name = item_attrs[:name] || item_attrs["name"]
        item_price = (item_attrs[:price] || item_attrs["price"] || 0).to_s.gsub(/[^\d.]/, '').to_f
        item_qty = (item_attrs[:qty] || item_attrs[:quantity] || item_attrs["qty"] || item_attrs["quantity"] || 1).to_i
        
        if item_name.present? && item_qty > 0
          if item_out_of_stock?(item_name)
            @out_of_stock_error = "#{item_name} is currently out of stock."
            next
          end
          order.order_items.build(name: item_name, price: item_price, quantity: item_qty, is_appended: is_appended)
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
          item_name = item_attrs[:name] || item_attrs[:item_name] || item_attrs["name"] || item_attrs["item_name"]
          item_price = (item_attrs[:price] || item_attrs["price"] || 0).to_s.gsub(/[^\d.]/, '').to_f
          item_qty = (item_attrs[:quantity] || item_attrs[:qty] || item_attrs["quantity"] || item_attrs["qty"] || 1).to_i
          
          if item_name.present?
            if item_out_of_stock?(item_name)
              @out_of_stock_error = "#{item_name} is currently out of stock."
              next
            end
            order.order_items.build(name: item_name, price: item_price, quantity: item_qty, is_appended: is_appended)
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
      :grand_total,
      :split_method_1, 
      :split_amount_1, 
      :split_method_2, 
      :split_amount_2,
      order_items_attributes: [:id, :menu_item_id, :name, :price, :quantity, :_destroy, :is_appended]
    )
  end
end