module LMSHelper
  def lms_user(syllabus, user_id)
    syllabus.user(user_id) || {}
  end

  def lms_user_match?(email, username, course)
    user = User.find_by_insensitive_email(email) unless email.blank?
    user ||= User.find_by_insensitive_username(username) unless username.blank?
    user.present? && !user.role(course).nil?
  end
end
