class CreateContainers < ActiveRecord::Migration[8.1]
  def change
    create_table :containers do |t|
      t.references :order, null: false, foreign_key: true
      t.string :packaging_type
      t.decimal :packaging_price

      t.timestamps
    end
  end
end
