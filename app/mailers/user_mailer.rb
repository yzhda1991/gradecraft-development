class UserMailer < ActionMailer::Base
  default from: "mailer@gradecraft.com"

  def activation_needed_email(user)
  end

  def reset_password_email(user)
    @user = user
    mail(:to => user.email, :subject => "Your GradeCraft Password Reset Instructions")
  end

end
