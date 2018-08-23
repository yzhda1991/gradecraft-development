# Core role authentication
module AuthenticationHelper
  def ensure_student?
    return not_authenticated unless current_user_is_student?
  end

  def ensure_staff?
    return not_authenticated unless current_user_is_staff?
  end

  def ensure_not_impersonating?
    redirect_to root_path unless !impersonating?
  end

  def ensure_prof?
    return not_authenticated unless current_user_is_professor?
  end

  def ensure_admin?
    return not_authenticated unless current_user_is_admin?
  end

  def ensure_not_observer?
    redirect_to assignments_path, alert: "You do not have permission to access that page" \
      if current_user_is_observer?
  end

  def ensure_course_uses_objectives?
    redirect_to dashboard_path unless current_course.uses_learning_objectives?
  end

  def ensure_app_environment?
    redirect_to dashboard_path, alert: "You do not have permission to do that" \
      unless accessible_to_app_env?
  end

  def require_course_membership
    redirect_to errors_path(status_code: 401, error_type: "without_course_membership") \
      unless current_user.course_memberships.any?
  end

  def accessible_to_app_env?
    Rails.env.development? || Rails.env.staging? || Rails.env.beta?
  end
end
