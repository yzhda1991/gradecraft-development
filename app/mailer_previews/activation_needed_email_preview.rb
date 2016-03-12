class ActivationNeededEmailPreview
  def activation_needed_email
    user = User.last
    user.activation_token = 102
    UserMailer.activation_needed_email user
  end
end