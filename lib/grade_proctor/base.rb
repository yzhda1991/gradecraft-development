class GradeProctor
  module Base

    private

    def grade_for_context?(user, course)
      resource.course_id == course.id && resource.student_id == user.id
    end
  end
end
