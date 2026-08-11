class StaffAuthMailer < ApplicationMailer
  def verification_code(user, otp)
    @user = user
    @otp = otp
    mail(to: @user.email, subject: "Your Newsong Cookitz Verification Code")
  end
end