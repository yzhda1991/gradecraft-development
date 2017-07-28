module Services
  module Actions
    class RunsGradeUpdaterJob
      extend LightService::Action

      expects :grade
      expects :run_jobs

      executed do |context|
        grade = context[:grade]
        if grade.student_visible? && context[:run_jobs]
          grade_updater_job = GradeUpdaterJob.new(grade_id: grade.id)
          grade_updater_job.enqueue
        end
      end
    end
  end
end
