require "light-service"
require_relative "creates_criterion/set_expectations_on_criterion"
require_relative "creates_criterion/set_expectations_on_levels"

module Services
  class UpdatesCriterionExpectations
    extend LightService::Organizer

    def self.call(criterion, level)
      with(
        criterion: criterion,
        level: level
      )
      .reduce(
        Actions::SetExpectationsOnCriterion,
        Actions::SetExpectationsOnLevels
      )
    end
  end
end
