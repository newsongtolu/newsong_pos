module Admin
  class DashboardsController < ApplicationController
    before_action :authenticate_user!

    def index
      @orders = Order.all

      # Define successfully fulfilled / paid order states
      valid_statuses = ['completed', 'served', 'delivered', 'paid', 'verified', 'out_for_delivery', 'ready_for_dispatch']
      valid_orders = @orders.where('LOWER(status) IN (?)', valid_statuses.map(&:downcase))

      # Payment method keywords
      paystack_keys = ['paystack', 'paystack_link', 'online', 'card_payment', 'link', 'online_payment']
      cash_keys     = ['cash']
      pos_keys      = ['pos', 'card']
      transfer_keys = ['transfer', 'bank_transfer', 'online_transfer']
      split_keys    = ['split', 'split_payment']

      # Fetch all payments linked to valid orders (supporting multi-leg and add-on payments)
      valid_payments = Payment.where(order_id: valid_orders.select(:id))

      # 1. Global Payment Method Breakdown (Powered by the payments table)
      @total_cash     = valid_payments.where('LOWER(payment_method) IN (?)', cash_keys).sum(:amount)
      @total_pos      = valid_payments.where('LOWER(payment_method) IN (?)', pos_keys).sum(:amount)
      @total_transfer = valid_payments.where('LOWER(payment_method) IN (?) OR LOWER(payment_method) LIKE ?', transfer_keys, '%transfer%').sum(:amount)
      @total_split    = valid_payments.where('LOWER(payment_method) IN (?)', split_keys).sum(:amount)
      @total_paystack = valid_payments.where('(LOWER(payment_method) IN (?) OR LOWER(payment_method) LIKE ?) AND LOWER(payment_method) NOT LIKE ?', paystack_keys, '%paystack%', '%transfer%').sum(:amount)
      @total_revenue  = valid_payments.sum(:amount)

      # 2. Total Delivery Fees Collected
      delivery_col = ['delivery_fee', 'shipping_fee', 'fee'].find { |c| Order.column_names.include?(c) }
      @total_delivery_fees = delivery_col ? valid_orders.sum(delivery_col.to_sym) : 0

      # 3. Granular Channel & Payment Disaggregation
      channels_config = {
        'dining' => { 
          name: 'Dining', 
          payment_type: :onsite,
          matcher: ->(o) { 
            val = (o.try(:fulfillment_type) || o.try(:service_mode) || o.try(:order_type) || '').to_s.downcase
            val.include?('dining') || val.include?('dine') || val.include?('sit')
          }
        },
        'physical_takeaway' => { 
          name: 'Physical Takeaway', 
          payment_type: :onsite,
          matcher: ->(o) { 
            val = (o.try(:fulfillment_type) || o.try(:service_mode) || o.try(:order_type) || '').to_s.downcase
            (val.include?('physical') || val.include?('counter') || val.include?('walk') || (val.include?('takeaway') && !val.include?('online'))) && !val.include?('online')
          }
        },
        'online_takeaway' => { 
          name: 'Online Takeaway', 
          payment_type: :online,
          matcher: ->(o) { 
            val = (o.try(:fulfillment_type) || o.try(:service_mode) || o.try(:order_type) || '').to_s.downcase
            val.include?('online') || val.include?('web') || val.include?('app') || val.include?('pickup') || val.include?('online_takeaway')
          }
        },
        'home_delivery' => { 
          name: 'Home Delivery', 
          payment_type: :online,
          matcher: ->(o) { 
            val = (o.try(:fulfillment_type) || o.try(:service_mode) || o.try(:order_type) || '').to_s.downcase
            val.include?('delivery') || val.include?('dispatch') || val.include?('doorstep') || val.include?('home') || val.include?('shipping')
          }
        }
      }

      @channel_metrics = {}
      channels_config.each do |slug, cfg|
        matched_orders = valid_orders.select { |o| cfg[:matcher].call(o) }
        matched_order_ids = matched_orders.map(&:id)
        matched_payments = valid_payments.where(order_id: matched_order_ids)
        
        scope_count = matched_orders.size
        scope_revenue = matched_payments.sum(:amount)

        channel_data = {
          name: cfg[:name],
          count: scope_count,
          revenue: scope_revenue
        }

        if cfg[:payment_type] == :onsite
          channel_data[:cash]     = matched_payments.where('LOWER(payment_method) IN (?)', cash_keys).sum(:amount)
          channel_data[:pos]      = matched_payments.where('LOWER(payment_method) IN (?)', pos_keys).sum(:amount)
          channel_data[:transfer] = matched_payments.where('LOWER(payment_method) IN (?) OR LOWER(payment_method) LIKE ?', transfer_keys, '%transfer%').sum(:amount)
          channel_data[:split]    = matched_payments.where('LOWER(payment_method) IN (?)', split_keys).sum(:amount)
        else
          channel_data[:paystack] = matched_payments.where('(LOWER(payment_method) IN (?) OR LOWER(payment_method) LIKE ?) AND LOWER(payment_method) NOT LIKE ?', paystack_keys, '%paystack%', '%transfer%').sum(:amount)
          channel_data[:transfer] = matched_payments.where('LOWER(payment_method) IN (?) OR LOWER(payment_method) LIKE ?', transfer_keys, '%transfer%').sum(:amount)
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