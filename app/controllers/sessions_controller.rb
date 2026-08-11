class SessionsController < Devise::SessionsController
  skip_before_action :verify_authenticity_token, only: [:create]

  # Intercept normal login
  def create
    user = User.find_by(email: params[:user][:email])

    if user && user.valid_password?(params[:user][:password])
      # 1. Generate a secure 5-digit code
      otp = rand(10000..99999).to_s
      user.update(otp_code: otp, otp_sent_at: Time.current)

      # 2. For development/testing: prints code to your terminal console
      Rails.logger.debug "========================================"
      Rails.logger.debug " 🔐 YOUR 5-DIGIT OTP CODE IS: #{otp}"
      Rails.logger.debug "========================================"

      # Optional: Send via ActionMailer if configured
      StaffAuthMailer.verification_code(user, otp).deliver_later rescue nil
      
      # 3. Store user ID temporarily in session
      session[:unverified_user_id] = user.id

      # 4. Redirect to the 5-digit verification page
      redirect_to verify_otp_path, notice: "A 5-digit verification code has been generated."
    else
      flash.now[:alert] = "Invalid email or password."
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  # Render the OTP input page
  def verify_otp
    redirect_to new_user_session_path unless session[:unverified_user_id]
  end

  # Confirm the 5-digit code entered by the user
  def confirm_otp
    user = User.find_by(id: session[:unverified_user_id])

    # Check if code matches and is less than 10 minutes old
    if user && user.otp_code == params[:otp_code] && user.otp_sent_at > 10.minutes.ago
      # Clear OTP data
      user.update(otp_code: nil, otp_sent_at: nil)
      session.delete(:unverified_user_id)

      # Fully log the user in using Devise
      sign_in(user)

      # Redirect cleanly based on their role
      redirect_after_sign_in(user)
    else
      flash.now[:alert] = "Invalid or expired verification code. Please try again."
      render :verify_otp, status: :unprocessable_entity
    end
  end

  private

  def redirect_after_sign_in(user)
    case user.role.to_sym
    when :super_admin then redirect_to super_admin_dashboards_path
    when :admin then redirect_to admin_dashboards_path
    when :cashier then redirect_to cashier_root_path
    when :kitchen then redirect_to kitchen_root_path
    when :floor then redirect_to floor_root_path
    when :dispatch then redirect_to dispatch_root_path
    else root_path
    end
  end
end