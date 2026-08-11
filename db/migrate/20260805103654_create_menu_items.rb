class CreateMenuItems < ActiveRecord::Migration[8.1]
  def change
    create_table :menu_items do |t|
      t.string :name
      t.text :description
      t.decimal :price
      t.string :category
      t.boolean :requires_double_container
      t.boolean :available

      t.timestamps
    end
  end
end
