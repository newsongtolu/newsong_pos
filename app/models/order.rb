class Order < ApplicationRecord
  has_many :order_items, dependent: :destroy
  has_many :payments, dependent: :destroy
  
  accepts_nested_attributes_for :order_items, allow_destroy: true, reject_if: :all_blank
  accepts_nested_attributes_for :payments, allow_destroy: true, reject_if: :all_blank
  
  # Virtual attributes for payment handling and split payments
  attr_accessor :new_payment_method, :split_method_1, :split_amount_1, :split_method_2, :split_amount_2
  
  before_validation :assign_defaults, on: :create
  before_save :calculate_grand_total

  # Scopes to separate Floor and Dispatch (handles spaces, underscores, and hyphens)
  scope :for_floor, -> { 
    where("LOWER(fulfillment_type) IN (?) OR LOWER(service_mode) IN (?)", 
          ["dine_in", "dine-in", "dine in", "physical_takeaway", "physical takeaway"], 
          ["dine_in", "dine-in", "dine in", "physical_takeaway", "physical takeaway"]) 
  }
  
  scope :for_dispatch, -> { 
    where("LOWER(fulfillment_type) IN (?) OR LOWER(service_mode) IN (?)", 
          ["online_takeaway", "online takeaway", "online-takeaway", "home_delivery", "home delivery", "home-delivery", "delivery"], 
          ["online_takeaway", "online takeaway", "online-takeaway", "home_delivery", "home delivery", "home-delivery", "delivery"]) 
  }

  def pending_review?
    status.to_s.downcase.in?(["pending", "pending_review"])
  end

  def verified?
    status.to_s.downcase == "verified"
  end

  # Helper method to check if a specific order belongs to the restaurant floor
  def floor_order?
    type_str = "#{fulfillment_type} #{service_mode}".downcase
    type_str.include?("dine") || type_str.include?("physical")
  end

  # Backward-compatible alias
  def flow_order?
    floor_order?
  end

  private

  def assign_defaults
    self.customer_name ||= "Self-Service Customer"
    self.grand_total ||= 0.00
    self.service_mode ||= "dine_in"
    self.fulfillment_type ||= "dine_in"
    self.status ||= "Pending"
    self.added_by ||= "customer"
  end

  def calculate_grand_total
    # Automatically sums up existing items and any newly added nested items
    items_total = order_items.reject(&:marked_for_destruction?).sum do |item|
      unit_price = item.price || item.menu_item&.price || 0.0
      unit_qty = item.quantity || 1
      unit_price * unit_qty
    end
    
    self.grand_total = items_total
    
    # If your database or form uses total_amount as an alias/column, keep this:
    if self.respond_to?(:total_amount=)
      self.total_amount = items_total
    end
  end
end