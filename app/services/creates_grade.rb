require "light-service"
require_relative "creates_grade/associates_submission_with_grade"
require_relative "creates_grade/builds_grade"
require_relative "creates_grade/marks_as_graded"
require_relative "creates_grade/runs_grade_updater_job"
require_relative "creates_grade/saves_grade"
require_relative "creates_grade/verifies_assignment_student"

module Services
  class CreatesGrade
    extend LightService::Organizer

    aliases raw_params: :attributes

    def self.call(raw_params, graded_by_id)
      with(raw_params: raw_params, graded_by_id: graded_by_id)
        .reduce(
          Actions::VerifiesAssignmentStudent,
          Actions::BuildsGrade,
          Actions::AssociatesSubmissionWithGrade,
          Actions::MarksAsGraded,
          Actions::SavesGrade,
          Actions::RunsGradeUpdaterJob
        )
    end
  end
end
