class Container < ApplicationRecord
  belongs_to :order
  has_many :order_items, dependent: :destroy
end