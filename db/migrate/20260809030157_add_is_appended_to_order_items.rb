class AddIsAppendedToOrderItems < ActiveRecord::Migration[8.1]
  def change
    add_column :order_items, :is_appended, :boolean
  end
end
