class GradeProctor
  module Updatable
    include Base

    def updatable?(user=nil, course=nil)
      return false if resource.nil?

      user ||= resource.student
      course ||= resource.course

      grade_for_context?(user, course) &&
        (user.is_staff?(course) || resource.assignment.student_logged? ||
         resource.predicted?)
    end
  end
end
