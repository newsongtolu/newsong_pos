class Setting < ApplicationRecord
  # Ensures there is always a settings record available in the database
  def self.current
    first_or_create!(
      app_name: "Newsong Cookitz",
      whatsapp_number: "+2340000000000",
      paystack_link: "https://paystack.pay/your-link",
      maintenance_mode: false
    )
  end
end