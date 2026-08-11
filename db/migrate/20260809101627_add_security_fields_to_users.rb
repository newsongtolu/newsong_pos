class AddSecurityFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :otp_code, :string
    add_column :users, :otp_sent_at, :datetime
    add_column :users, :failed_login_attempts, :integer
    add_column :users, :lock_until, :datetime
  end
end
