require "light-service"
require_relative "shared/iterates_assignment_groups_to_create_grades"
require "creates_grade/assert_result_from_many_outcomes"

module Services
  class CreatesManyGroupGrades
    extend LightService::Organizer

    def self.call(assignment_id, graded_by_id, grades_by_group_params)
      with(assignment_id: assignment_id, graded_by_id: graded_by_id, grades_by_group_params: grades_by_group_params)
        .reduce(
          Actions::IteratesAssignmentGroupsToCreateGrades,
          Actions::AssertResultFromManyOutcomes
        )
    end
  end
end
