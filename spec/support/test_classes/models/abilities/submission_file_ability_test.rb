require "cancan"
require_relative "../../../../../app/models/abilities/submission_file_ability"

class SubmissionFileAbilityTest
  include CanCan::Ability
  include SubmissionFileAbility

  def initialize(user)
    define_submission_file_abilities user
  end
end

