# Preview all emails at http://localhost:3000/rails/mailers/staff_auth_mailer
class StaffAuthMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/staff_auth_mailer/verification_code
  def verification_code
    StaffAuthMailer.verification_code
  end
end
