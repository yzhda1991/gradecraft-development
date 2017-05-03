module LMSHelper
  def lms_user(syllabus, user_id)
    syllabus.user(user_id) || {}
  end

  def lms_user_match?(email, course)
    user = User.find_by_insensitive_email(email)
    user.present? && !user.role(course).nil?
  end
end
