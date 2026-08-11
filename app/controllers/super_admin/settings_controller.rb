module SuperAdmin
  class SettingsController < ApplicationController
    before_action :authenticate_user!

    def index
      @app_setting = AppSetting.first || AppSetting.create!
    end

    def update
      @app_setting = AppSetting.first || AppSetting.new(settings_params)
      if @app_setting.update(settings_params)
        redirect_to super_admin_settings_path, notice: "Master system configuration successfully updated."
      else
        render :index, status: :unprocessable_entity
      end
    end

    private

    def settings_params
      params.require(:app_setting).permit(
        :restaurant_name, 
        :tax_rate, 
        :currency, 
        :maintenance_mode, 
        :operational_mode, 
        :allow_staff_override, 
        :receipt_footer_note,
        :get_started_link,    # If you added this too
        :paystack_link,       # New
        :whatsapp_number      # New
      )
    end
  end
end