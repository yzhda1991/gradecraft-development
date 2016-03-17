class GradeProctor
  module Base

    private

    def grade_for_context?(user, course)
      grade.course_id == course.id && grade.student_id == user.id
    end
  end
end
