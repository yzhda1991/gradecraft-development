class GradeProctor
  module Viewable
    def viewable?(user, course)
      grade_for_context?(user, course) &&
        (user.is_staff?(course) || grade_visible_by_student?(user, course))
    end

    private

    def grade_for_context?(user, course)
      resource.course_id == course.id && resource.student_id == user.id
    end

    def grade_visible_by_student?(user, course)
      resource.is_released? ||
        (resource.is_graded? && !resource.assignment.release_necessary?)
    end
  end
end
