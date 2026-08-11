class PaymentTransaction < ApplicationRecord
  belongs_to :order
end
