class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :container, optional: true
end