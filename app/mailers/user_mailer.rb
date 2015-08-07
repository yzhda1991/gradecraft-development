class UserMailer < ActionMailer::Base
  default from: "mailer@gradecraft.com"

  def activation_needed_email(user)
    @user = user
    mail to: @user.email,
         subject: " Welcome to GradeCraft! Please activate your account"
  end

  def reset_password_email(user)
    @user = user
    mail(:to => user.email, :subject => "Your GradeCraft Password Reset Instructions")
  end

end
