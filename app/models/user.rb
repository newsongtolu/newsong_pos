class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Define your roles enum mapping integers to role names
  enum :role, {
    cashier: 0,
    kitchen: 1,
    floor: 2,
    dispatch: 3,
    manager: 4,
    admin: 5,
    super_admin: 6
  }, default: :cashier

  def locked?
    lock_until.present? && lock_until > Time.current
  end

  def reset_lockout!
    update(failed_login_attempts: 0, lock_until: nil)
  end

  def increment_failed_attempts!
    new_attempts = (failed_login_attempts || 0) + 1
    if new_attempts >= 2
      update(failed_login_attempts: new_attempts, lock_until: 15.minutes.from_now)
    else
      update(failed_login_attempts: new_attempts)
    end
  end
end