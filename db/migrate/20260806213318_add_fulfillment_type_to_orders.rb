class AddFulfillmentTypeToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :fulfillment_type, :string
  end
end
