class CreateSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :settings do |t|
      t.string :key
      t.string :value
      t.text :description

      t.timestamps
    end
  end
end
