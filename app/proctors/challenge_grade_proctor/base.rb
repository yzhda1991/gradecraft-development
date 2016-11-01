# common methods for CRUD operations on a `ChallengeGrade`
class ChallengeGradeProctor
  module Base

    private

    def challenge_grade_for_course?(course)
      challenge_grade.team.course_id == course.id
    end
  end
end
