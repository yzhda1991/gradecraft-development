require "light-service"
require_relative "creates_grade/builds_grade"
require_relative "creates_grade/associates_submission_with_grade"
require_relative "creates_grade/marks_as_graded"
require_relative "creates_grade/saves_grade"
require_relative "creates_grade/runs_grade_updater_job"


# This grade service is called from GradesController#update
# This service should merged with CreatesGrade when grading
# routes are cleaned up and params are standardized
module Services
  class UpdatesGrade
    extend LightService::Organizer

    aliases attributes: :raw_params

    def self.create(grade, attributes, graded_by_id)
      with(grade: grade,
           student: grade.student,
           assignment: grade.assignment,
           attributes: attributes,
           graded_by_id: graded_by_id)
        .reduce(
          Actions::BuildsGrade,
          Actions::AssociatesSubmissionWithGrade,
          Actions::MarksAsGraded,
          Actions::SavesGrade,
          Actions::RunsGradeUpdaterJob
        )
    end
  end
end
