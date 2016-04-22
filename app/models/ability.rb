require_relative "abilities/assignment_weight_ability"
require_relative "abilities/announcement_ability"
require_relative "abilities/grade_ability"
require_relative "abilities/challenge_grade_ability"
require_relative "abilities/submission_ability"
require_relative "abilities/submission_file_ability"

class Ability
  include CanCan::Ability
  include AssignmentWeightAbility
  include AnnouncementAbility
  include GradeAbility
  include ChallengeGradeAbility
  include SubmissionAbility
  include SubmissionFileAbility

  def initialize(user, course)
    define_assignment_weight_abilities user, course
    define_announcement_abilities user, course
    define_challenge_grade_abilities user, course
    define_grade_abilities user, course
    define_submission_abilities user, course
    define_submission_file_abilities user, course
  end
end
