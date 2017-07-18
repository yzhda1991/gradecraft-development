require_relative "../../background_jobs/grade_updater_job"

module Services
  module Actions
    class EnqueuesGradeUpdaterJobs
      extend LightService::Action

      expects :grades_import_result

      executed do |context|
        result = context.grades_import_result

        result.successful.each do |grade|
          if grade.student_visible?
            GradeUpdaterJob.new(grade_id: grade.id).enqueue
          end
        end unless result.nil?
      end
    end
  end
end
