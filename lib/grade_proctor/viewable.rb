class GradeProctor
  module Viewable
    def viewable?(context)
      resource.student_id == context.id &&
        (resource.is_released? ||
         (resource.is_graded? && !resource.assignment.release_necessary?))
    end
  end
end
