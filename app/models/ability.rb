require_relative "abilities/announcement_ability"
require_relative "abilities/grade_ability"

class Ability
  include CanCan::Ability
  include AnnouncementAbility
  include GradeAbility

  def initialize(user, course)
    define_announcement_abilities user, course
    define_grade_abilities user, course
  end
end
