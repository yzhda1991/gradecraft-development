# determines if a `Grade` resource can be updated within a specific
# user and course context
class GradeProctor
  module Updatable
    include Base

    def updatable?(user=nil, course=nil)
      return false if grade.nil?

      user ||= grade.student
      course ||= grade.course

      grade_for_course?(course) &&
        (user.is_staff?(course) ||
          (grade_for_user?(user) && (grade.assignment.student_logged? || grade.predicted?)))
    end
  end
end
