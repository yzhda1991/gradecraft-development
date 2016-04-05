# Determines if a `Grade` resource can be updated by a user. If no user is
# supplied in the options, it will default to the Grade's student.
#
# Options include:
#   course:  Will verify the grade is for the course
#   user:    Determines permissions for supplied user rather than the
#            grade's student
#
class GradeProctor
  module Updatable
    include Base

    def updatable?(options={})
      return false if grade.nil?

      user = options[:user] || grade.student
      course = options[:course] || grade.course

      grade_for_course?(course) &&
        (user.is_staff?(course) ||
          (grade_for_user?(user) && grade.assignment.student_logged?))
    end
  end
end
