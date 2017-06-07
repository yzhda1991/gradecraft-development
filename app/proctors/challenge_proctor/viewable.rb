# Determines if a `Challenge` resource can be viewed for a specific user
#
# Options include:
#   course:  Will verify the challenge is for the course.
#   team:   Will only show students invisible badges earned for the specific
#            level. This is used for Rubric views to hide all invisible level
#            badges on unearned levels, even if the student earned the badge in
#            another context.
#
class ChallengeProctor
  module Viewable
    include Base

    def viewable?(team, options={})
      return false if challenge.nil?

      course = options[:course] || challenge.course
      challenge_for_course?(course) &&
        (user.is_staff?(course) || challenge_visible_by_team?(team, challenge))
    end

    private

    def challenge_visible_by_team?(team, challenge)
      challenge.visible? || challenge_grades_visible_by_team?(team, challenge)
    end

    def challenge_grades_visible_by_team?(team, challenge)
      ChallengeGrade.where(team_id: team.id, challenge_id: challenge.id, student_visible: true).present?
    end
  end
end
