# common methods for CRUD operations on a `Grade`
class ChallengeProctor
  module Base

    private

    def challenge_for_course?(course)
      challenge.course_id == course.id
    end
  end
end
