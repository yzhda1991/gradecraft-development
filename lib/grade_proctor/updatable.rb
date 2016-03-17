class GradeProctor
  module Updatable
    include Base

    def updatable?(user=nil, course=nil)
      return false if grade.nil?

      user ||= grade.student
      course ||= grade.course

      grade_for_context?(user, course) &&
        (user.is_staff?(course) || grade.assignment.student_logged? ||
         grade.predicted?)
    end
  end
end
