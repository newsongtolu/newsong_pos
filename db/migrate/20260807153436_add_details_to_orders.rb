class AddDetailsToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :payment_method, :string
    add_column :orders, :phone, :string
    add_column :orders, :email, :string
  end
end
