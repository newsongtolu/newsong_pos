class AddCategoryToMenuItems < ActiveRecord::Migration[8.0]
  def change
    add_reference :menu_items, :category, null: true, foreign_key: true
  end
end