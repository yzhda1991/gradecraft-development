class GradeProctor
  module Viewable
    include Base

    def viewable?(user=nil, course=nil)
      return false if resource.nil?

      user ||= resource.student
      course ||= resource.course

      grade_for_context?(user, course) &&
        (user.is_staff?(course) || grade_visible_by_student?)
    end

    private

    def grade_visible_by_student?
      resource.is_released? ||
        (resource.is_graded? && !resource.assignment.release_necessary?)
    end
  end
end
