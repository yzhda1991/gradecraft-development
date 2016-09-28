require "cancan"
require_dependency "abilities/announcement_ability"
require_dependency "abilities/assignment_type_weight_ability"
require_dependency "abilities/challenge_grade_ability"
require_dependency "abilities/course_ability"
require_dependency "abilities/grade_ability"
require_dependency "abilities/submission_ability"
require_dependency "abilities/submission_file_ability"

class Ability
  include CanCan::Ability
  include CourseAbility
  include AnnouncementAbility
  include AssignmentTypeWeightAbility
  include ChallengeGradeAbility
  include GradeAbility
  include SubmissionAbility
  include SubmissionFileAbility

  def initialize(user, course)
    define_course_abilities user
    define_announcement_abilities user, course
    define_assignment_weight_abilities user, course
    define_challenge_grade_abilities user, course
    define_grade_abilities user, course
    define_submission_abilities user, course
    define_submission_file_abilities user
  end
end
