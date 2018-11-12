class AdminConstraint
  def matches?(request)
    return false if request.session[:user_id].blank?
    user = User.find request.session[:user_id]
    user.present? && user.admin?
  end
end
