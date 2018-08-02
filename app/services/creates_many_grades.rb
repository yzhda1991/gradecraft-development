require "light-service"
require "shared/iterates_grade_attributes"
require "creates_grade/assert_result_from_many_outcomes"

module Services
  class CreatesManyGrades
    extend LightService::Organizer

    def self.call(assignment_id, graded_by_id, grade_attributes)
      with(grade_attributes: grade_attributes, assignment_id: assignment_id, graded_by_id: graded_by_id)
        .reduce(
          Actions::IteratesGradeAttributes,
          Actions::AssertResultFromManyOutcomes
        )
    end
  end
end
