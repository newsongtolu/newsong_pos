class AddMissingFieldsToOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :customer_name, :string unless column_exists?(:orders, :customer_name)
    add_column :orders, :grand_total, :decimal unless column_exists?(:orders, :grand_total)
    add_column :orders, :service_mode, :string unless column_exists?(:orders, :service_mode)
    add_column :orders, :fulfillment_type, :string unless column_exists?(:orders, :fulfillment_type)
    add_column :orders, :notes, :text unless column_exists?(:orders, :notes)
    add_column :orders, :status, :string unless column_exists?(:orders, :status)
    add_column :orders, :added_by, :string unless column_exists?(:orders, :added_by)
  end
end