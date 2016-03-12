class ResetPasswordEmailPreview
  def reset_password_email
    user = User.last
    user.reset_password_token = 101
    UserMailer.reset_password_email user
  end
end