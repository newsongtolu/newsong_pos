class AddSupportAndPaymentLinksToAppSettings < ActiveRecord::Migration[8.0]
  def change
    add_column :app_settings, :paystack_link, :string unless column_exists?(:app_settings, :paystack_link)
    add_column :app_settings, :whatsapp_number, :string unless column_exists?(:app_settings, :whatsapp_number)
  end
end