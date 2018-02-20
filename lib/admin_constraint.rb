class AdminConstraint
  def matches?(request)
    user = User.find request.session[:user_id]
    user.present? && user.admin?
  end
end
