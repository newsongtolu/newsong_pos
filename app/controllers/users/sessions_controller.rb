module Users
  class SessionsController < Devise::SessionsController
    def create
      user = User.find_by(email: params[:user][:email])

      if user && user.valid_password?(params[:user][:password])
        otp = rand(10000..99999).to_s
        user.update(otp_code: otp, otp_sent_at: Time.current)

        # Bulletproof direct output to STDOUT so Railway logs capture it instantly
        otp_banner = "\n========================================\n 🔐 YOUR 5-DIGIT OTP CODE IS: #{otp}\n========================================"
        STDOUT.puts otp_banner
        STDOUT.flush
        Rails.logger.warn otp_banner

        begin
          StaffAuthMailer.verification_code(user, otp).deliver_later
        rescue => e
          Rails.logger.warn "Email delivery skipped or failed: #{e.message}"
        end
        
        session[:otp_user_id] = user.id

        respond_to do |format|
          format.html { redirect_to verify_otp_path, notice: "A 5-digit verification code has been generated.", status: :see_other }
        end
      else
        flash.now[:alert] = "Invalid email or password."
        self.resource = resource_class.new(sign_in_params)
        respond_to do |format|
          format.html { render :new, status: :unprocessable_entity }
        end
      end
    end

    def verify_otp
      @user = User.find_by(id: session[:otp_user_id])
      if @user
        @email = @user.email
      else
        redirect_to new_user_session_path, alert: "Verification session expired. Please sign in again.", status: :see_other
      end
    end

    def confirm_otp
      user = User.find_by(id: session[:otp_user_id])
      unless user
        redirect_to new_user_session_path, alert: "Verification session expired. Please sign in again.", status: :see_other and return
      end

      if user.otp_code == params[:otp_code] && user.otp_sent_at && user.otp_sent_at > 10.minutes.ago
        user.update(otp_code: nil, otp_sent_at: nil)
        session.delete(:otp_user_id)
        
        sign_in(user)
        redirect_after_sign_in(user)
      else
        @email = user.email
        flash.now[:alert] = "Invalid or expired verification code. Please try again."
        render :verify_otp, status: :unprocessable_entity
      end
    end

    private

    def redirect_after_sign_in(user)
      case user.role.try(:to_sym)
      when :super_admin then redirect_to super_admin_dashboards_path, status: :see_other
      when :admin then redirect_to admin_dashboards_path, status: :see_other
      when :cashier then redirect_to cashier_root_path, status: :see_other
      when :kitchen then redirect_to kitchen_root_path, status: :see_other
      when :floor then redirect_to floor_root_path, status: :see_other
      when :dispatch then redirect_to dispatch_root_path, status: :see_other
      else redirect_to root_path, status: :see_other
      end
    end
  end
end