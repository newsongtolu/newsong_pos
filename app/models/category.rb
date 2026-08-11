class Category < ApplicationRecord
  has_many :menu_items, dependent: :nullify
  validates :name, presence: true, uniqueness: true
end