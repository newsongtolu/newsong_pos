class SessionsController < Devise::SessionsController
  skip_before_action :verify_authenticity_token, only: [:create, :confirm_otp]

  def create
    self.resource = warden.authenticate(auth_options)

    if resource.nil?
      flash[:alert] = "Invalid email or password."
      respond_with_navigational(resource) { redirect_to new_user_session_path }
      return
    end

    if resource.locked?
      sign_out(resource)
      time_left = ((resource.lock_until - Time.current) / 60).ceil
      flash[:alert] = "Account locked. Try again in #{time_left} minutes."
      respond_with_navigational(resource) { redirect_to new_user_session_path }
      return
    end

    # Generate 5-digit code and send email
    code = rand(10000..99999).to_s
    resource.update(otp_code: code, otp_sent_at: Time.current, failed_login_attempts: 0)
    StaffAuthMailer.verification_code(resource, code).deliver_later

    Rails.logger.info "========================================="
    Rails.logger.info "🔑 YOUR LOGIN OTP CODE IS: #{code}"
    Rails.logger.info "========================================="

    sign_out(resource)
    session[:pending_otp_user_id] = resource.id

    redirect_to verify_otp_path, notice: "Verification code sent to your email."
  end

  def verify_otp
    @pending_user = User.find_by(id: session[:pending_otp_user_id])
    unless @pending_user
      redirect_to new_user_session_path, alert: "Session expired. Please log in again."
    end
  end

  def confirm_otp
    @pending_user = User.find_by(id: session[:pending_otp_user_id])

    unless @pending_user
      redirect_to new_user_session_path, alert: "Session expired. Please log in again."
      return
    end

    entered_code = params[:otp_code].to_s.strip
    stored_code = @pending_user.otp_code.to_s.strip

    Rails.logger.info "========================================="
    Rails.logger.info "🔍 ENTERED: '#{entered_code}' vs STORED: '#{stored_code}'"
    Rails.logger.info "========================================="

    if entered_code == stored_code && entered_code.present?
      session.delete(:pending_otp_user_id)
      sign_in(:user, @pending_user)
      @pending_user.update(otp_code: nil, failed_login_attempts: 0)

      redirect_to role_dashboard_path(@pending_user), notice: "Signed in successfully."
    else
      @pending_user.increment_failed_attempts! rescue nil
      flash.now[:alert] = "Invalid verification code."
      render :verify_otp, status: :unprocessable_entity
    end
  end

  protected

  def after_sign_in_path_for(resource)
    role_dashboard_path(resource)
  end

  private

  def role_dashboard_path(user)
    role_val = user.respond_to?(:role) ? user.role.to_s.downcase.strip : ""
    email = user.email.to_s.downcase.strip

    Rails.logger.info "========================================="
    Rails.logger.info "🎯 ROUTING USER: #{email} | ROLE VALUE: #{role_val.inspect}"
    Rails.logger.info "========================================="

    case role_val
    when "super_admin", "superadmin", "5", "6"
      admin_users_path
    when "admin", "5"
      admin_users_path
    when "manager", "4"
      manager_dashboard_index_path
    when "kitchen", "1"
      kitchen_orders_path
    when "floor", "2"
      floor_orders_path
    when "dispatch", "3"
      dispatch_orders_path
    when "cashier", "0"
      cashier_orders_path
    else
      if email.include?("admin") || email.include?("super")
        admin_users_path
      elsif email.include?("manager")
        manager_dashboard_index_path
      elsif email.include?("kitchen")
        kitchen_orders_path
      elsif email.include?("floor")
        floor_orders_path
      elsif email.include?("dispatch")
        dispatch_orders_path
      else
        cashier_orders_path
      end
    end
  end
end