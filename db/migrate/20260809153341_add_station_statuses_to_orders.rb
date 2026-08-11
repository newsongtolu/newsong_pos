class AddStationStatusesToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :floor_status, :string
    add_column :orders, :dispatch_status, :string
  end
end
