class CourseMembershipValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if record.course.present? && value.present?
      user = value
      unless CourseMembership.where(course_id: record.course.id, user_id: user.id).exists?
        record.errors[attribute] << "must belong to the course"
      end
    end
  end
end
