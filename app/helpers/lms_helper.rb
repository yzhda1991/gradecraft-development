module LMSHelper
  ROLES_BY_PRECEDENCE = {
    TeacherEnrollment: 4,
    DesignerEnrollment: 3,
    TaEnrollment: 2,
    StudentEnrollment: 1,
    ObserverEnrollment: 0
  }

  def lms_user(syllabus, user_id)
    syllabus.user(user_id) || {}
  end

  def lms_user_match?(email, course)
    user = User.find_by_insensitive_email(email)
    user.present? && user.is_student?(course)
  end

  # Pluck from an array of LMS enrollments the one of greatest precedence and
  # translate to a Gradecraft role
  def lms_user_role(enrollments)
    lms_role = find_principal_role enrollments
    return :observer if lms_role.nil?

    case lms_role.downcase
    when "studentenrollment"
      :student
    when "teacherenrollment"
      :professor
    when "taenrollment", "designerenrollment"
      :gsi
    else
      :observer
    end
  end

  private

  # Return only the role with the highest level of precedence in Gradecraft
  def find_principal_role(enrollments)
    active_enrollments = enrollments.select { |e| e["enrollment_state"] == "active" }
    principal_enrollment = active_enrollments.max_by do |enrollment|
      lms_role = enrollment["type"]
      ROLES_BY_PRECEDENCE[lms_role.to_sym]
    end
    principal_enrollment["type"] unless principal_enrollment.nil?
  end
end
