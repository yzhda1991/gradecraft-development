module LMSHelper
  def lms_user(syllabus, user_id)
    syllabus.user(user_id) || {}
  end

  def lms_user_match?(email)
    !User.find_by_insensitive_email(email).nil?
  end
end
