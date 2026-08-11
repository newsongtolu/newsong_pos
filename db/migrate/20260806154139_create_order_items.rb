class CreateOrderItems < ActiveRecord::Migration[8.1]
  def change
    create_table :order_items do |t|
      t.references :order, null: false, foreign_key: true
      t.references :container, null: false, foreign_key: true
      t.string :item_name
      t.decimal :item_price
      t.integer :quantity

      t.timestamps
    end
  end
end
