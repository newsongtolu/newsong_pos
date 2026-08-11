module Admin
  class DashboardsController < ApplicationController
    before_action :authenticate_user!

    def index
      @orders = Order.all

      # Define successfully fulfilled / paid order states
      valid_statuses = ['completed', 'served', 'delivered', 'paid', 'Verified']
      valid_orders = @orders.where(status: valid_statuses)

      # 1. Global Payment Method Breakdown (Cash Control & Reconciliation)
      @total_cash     = valid_orders.where('LOWER(payment_method) = ?', 'cash').sum(:grand_total)
      @total_pos      = valid_orders.where('LOWER(payment_method) IN (?)', ['pos', 'card']).sum(:grand_total)
      @total_transfer = valid_orders.where('LOWER(payment_method) IN (?)', ['transfer', 'bank_transfer']).sum(:grand_total)
      @total_split    = valid_orders.where('LOWER(payment_method) IN (?)', ['split', 'split_payment']).sum(:grand_total)
      @total_paystack = valid_orders.where('LOWER(payment_method) IN (?)', ['paystack', 'paystack_link', 'online']).sum(:grand_total)
      @total_revenue  = @total_cash + @total_pos + @total_transfer + @total_split + @total_paystack

      # 2. Total Delivery Fees Collected
      delivery_col = ['delivery_fee', 'shipping_fee', 'fee'].find { |c| Order.column_names.include?(c) }
      @total_delivery_fees = delivery_col ? valid_orders.sum(delivery_col.to_sym) : 0

      # 3. Granular Channel & Payment Disaggregation
      channels_config = {
        'dining'            => { name: 'Dining', keys: ['dining', 'dine_in', 'dine-in', 'sit_in', 'rest'], payment_type: :onsite },
        'physical_takeaway' => { name: 'Physical Takeaway', keys: ['physical', 'takeaway', 'take-away', 'takeout', 'walk', 'counter', 'pos_walk'], payment_type: :onsite },
        'online_takeaway'   => { name: 'Online Takeaway', keys: ['online', 'web', 'pickup', 'app'], payment_type: :online },
        'home_delivery'     => { name: 'Home Delivery', keys: ['delivery', 'dispatch', 'doorstep', 'home', 'shipping'], payment_type: :online }
      }

      available_columns = ['service_mode', 'fulfillment_type', 'order_type', 'service_type', 'channel'].select { |c| Order.column_names.include?(c) }

      @channel_metrics = {}
      channels_config.each do |slug, cfg|
        scope = valid_orders

        if available_columns.any?
          conditions = []
          bind_values = []
          available_columns.each do |col|
            cfg[:keys].each do |key|
              conditions << "LOWER(#{col}) LIKE ?"
              bind_values << "%#{key}%"
            end
          end
          scope = scope.where(conditions.join(' OR '), *bind_values)
        else
          scope = (slug == 'physical_takeaway') ? valid_orders : valid_orders.none
        end

        channel_data = {
          name: cfg[:name],
          count: scope.count,
          revenue: scope.sum(:grand_total)
        }

        if cfg[:payment_type] == :onsite
          channel_data[:cash]     = scope.where('LOWER(payment_method) = ?', 'cash').sum(:grand_total)
          channel_data[:pos]      = scope.where('LOWER(payment_method) IN (?)', ['pos', 'card']).sum(:grand_total)
          channel_data[:transfer] = scope.where('LOWER(payment_method) IN (?)', ['transfer', 'bank_transfer']).sum(:grand_total)
          channel_data[:split]    = scope.where('LOWER(payment_method) IN (?)', ['split', 'split_payment']).sum(:grand_total)
        else
          channel_data[:paystack] = scope.where('LOWER(payment_method) IN (?)', ['paystack', 'paystack_link', 'online']).sum(:grand_total)
        end

        @channel_metrics[slug] = channel_data
      end

      # 4. Packaging / Container Revenue Disaggregation
      valid_order_ids = valid_orders.select(:id)
      container_records = defined?(Container) ? Container.where(order_id: valid_order_ids) : []
      @container_breakdown = container_records.any? ? container_records.group(:packaging_type).sum(:packaging_price) : {}
      @total_packaging_revenue = container_records.any? ? container_records.sum(:packaging_price) : 0

      # Core Food Revenue (Gross Revenue minus Packaging and Delivery Fees)
      @core_food_revenue = @total_revenue - @total_packaging_revenue - @total_delivery_fees

      @completed_orders_count = valid_orders.count
    end
  end
end