require "light-service"
require_relative "creates_grade/runs_grade_updater_job"
require_relative "shared/updates_grade_status_fields"


# Substitute for all loose calls to Grade Updater.
#  Assignments::GradesController#update_status
#  Assignments::GradesController#self_log
# Grades::ImportersController#upload
#
# Also: need to call the action from
# ImportsLMSGrades
#
# I'm starting to think this should just be handled in a
# before save action, there are too many ways to create a grade
module Services
  class UpdatesGradeStatus
    extend LightService::Organizer

    aliases attributes: :raw_params

    def self.update(grade, grade_params, graded_by_id)
      with(grade: grade,
           student: grade.student,
           assignment: grade.assignment,
           attributes: {"grade" => grade_params},
           graded_by_id: graded_by_id)
        .reduce(
          Actions::UpdatesGradeStatusFields,
          Actions::RunsGradeUpdaterJob
        )
    end
  end
end
