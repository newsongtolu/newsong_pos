class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email
      t.string :password_digest
      t.integer :role
      t.string :name
      t.string :phone
      t.boolean :active

      t.timestamps
    end
  end
end
