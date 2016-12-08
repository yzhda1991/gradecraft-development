require "cancan"
require_relative "abilities/announcement_ability"
require_relative "abilities/assignment_type_weight_ability"
require_relative "abilities/challenge_grade_ability"
require_relative "abilities/course_ability"
require_relative "abilities/grade_ability"
require_relative "abilities/submission_ability"
require_relative "abilities/submission_file_ability"
require_relative "abilities/earned_badge_ability"

class Ability
  include CanCan::Ability
  include CourseAbility
  include AnnouncementAbility
  include AssignmentTypeWeightAbility
  include ChallengeGradeAbility
  include GradeAbility
  include SubmissionAbility
  include SubmissionFileAbility
  include EarnedBadgeAbility

  def initialize(user, course)
    define_course_abilities user
    define_announcement_abilities user, course
    define_assignment_weight_abilities user, course
    define_challenge_grade_abilities user, course
    define_grade_abilities user, course
    define_submission_abilities user, course
    define_submission_file_abilities user
    define_earned_badge_abilities user
  end
end
