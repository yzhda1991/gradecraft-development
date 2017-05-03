module CanvasAPIHelper
  ROLES_BY_PRECEDENCE = {
    TeacherEnrollment: 4,
    DesignerEnrollment: 3,
    TaEnrollment: 2,
    StudentEnrollment: 1,
    ObserverEnrollment: 0
  }

  def concat_submission_comments(comments, separator="; ")
    return nil if comments.blank?
    comments.pluck("comment").each_with_index.map do |comment, i|
      "Comment #{i+1}: #{comment}"
    end.join(separator)
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
