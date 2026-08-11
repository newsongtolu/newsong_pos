class ChangeContainerIdNullOnOrderItems < ActiveRecord::Migration[8.0]
  def change
    change_column_null :order_items, :container_id, true
  end
end