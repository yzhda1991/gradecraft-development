require "light-service"
require_relative "creates_criterion/remove_expectations_on_criterion"
require_relative "creates_criterion/remove_expectations_on_levels"

module Services
  class RemovesCriterionExpectations
    extend LightService::Organizer

    def self.call(criterion)
      with(
        criterion: criterion
      )
      .reduce(
        Actions::RemoveExpectationsOnCriterion,
        Actions::RemoveExpectationsOnLevels
      )
    end
  end
end
