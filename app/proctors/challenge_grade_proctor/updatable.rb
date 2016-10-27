# Determines if a `ChallengeGrade` resource can be updated by a user.
#
# Options include:
#   course:  Will verify the challenge grade is for the course
#   user:    Determines permissions for supplied user
#
class ChallengeGradeProctor
  module Updatable
    include Base

    def updatable?(options={})
      return false if challenge_grade.nil?

      user = options[:user]
      course = options[:course]

      challenge_grade_for_course?(course) && user.is_staff?(course)
    end
  end
end
