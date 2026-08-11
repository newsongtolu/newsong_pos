class AddInStockToMenuItems < ActiveRecord::Migration[8.0]
  def change
    add_column :menu_items, :in_stock, :boolean, default: true, null: false
  end
end