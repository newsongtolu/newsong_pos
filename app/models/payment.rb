class Payment < ApplicationRecord
  belongs_to :order

  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :payment_method, presence: true
end