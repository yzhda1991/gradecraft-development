# Determines if a `ChallengeGrade` resource can be viewed by a user.
#
# Options include:
#   course:  Will verify the challenge grade is for the course
#   user:    Determines permissions for supplied user
#
class ChallengeGradeProctor
  module Viewable
    include Base

    def viewable?(options={})
      return false if challenge_grade.nil?

      user = options[:user]
      course = options[:course] || challenge_grade.team.course

      challenge_grade_for_course?(course) &&
        ((user.present? && user.is_staff?(course)) || challenge_grade.student_visible?
    end
  end
end
