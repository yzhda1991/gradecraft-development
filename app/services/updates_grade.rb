require "light-service"
require_relative "creates_grade/associates_submission_with_grade"
require_relative "creates_grade/builds_grade"
require_relative "creates_grade/marks_as_graded"
require_relative "creates_grade/saves_grade"
require_relative "creates_grade/squish_grade_history"

# This grade service is called from GradesController#update
# It's possible this service could be combined with CreatesGrade
# when grading routes are cleaned up and params are standardized
module Services
  class UpdatesGrade
    extend LightService::Organizer

    aliases attributes: :raw_params

    def self.call(grade, grade_params, graded_by_id)
      with(grade: grade,
           student: grade.student,
           assignment: grade.assignment,
           attributes: {"grade" => grade_params},
           graded_by_id: graded_by_id)
        .reduce(
          Actions::BuildsGrade,
          Actions::AssociatesSubmissionWithGrade,
          Actions::MarksAsGraded,
          Actions::SavesGrade,
          Actions::SquishGradeHistory
        )
    end
  end
end
