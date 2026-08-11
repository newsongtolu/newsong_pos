class CreateAppSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :app_settings do |t|
      t.string :app_name
      t.string :whatsapp_number
      t.string :paystack_link
      t.boolean :maintenance_mode

      t.timestamps
    end
  end
end
