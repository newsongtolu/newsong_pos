class AddMasterControlsToAppSettings < ActiveRecord::Migration[8.0]
  def change
    add_column :app_settings, :maintenance_mode, :boolean unless column_exists?(:app_settings, :maintenance_mode)
    add_column :app_settings, :operational_mode, :string unless column_exists?(:app_settings, :operational_mode)
    add_column :app_settings, :allow_staff_override, :boolean unless column_exists?(:app_settings, :allow_staff_override)
    add_column :app_settings, :receipt_footer_note, :string unless column_exists?(:app_settings, :receipt_footer_note)
  end
end