class AddDetailsToOrderItems < ActiveRecord::Migration[8.0]
  def change
    add_column :order_items, :name, :string unless column_exists?(:order_items, :name)
    add_column :order_items, :price, :decimal unless column_exists?(:order_items, :price)
    add_column :order_items, :quantity, :integer unless column_exists?(:order_items, :quantity)
  end
end