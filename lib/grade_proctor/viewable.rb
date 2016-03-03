class GradeProctor
  module Viewable
    def viewable?(user, course)
      resource.course_id == course.id &&
        resource.student_id == user.id &&
          (resource.is_released? ||
           (resource.is_graded? && !resource.assignment.release_necessary?))
    end
  end
end
