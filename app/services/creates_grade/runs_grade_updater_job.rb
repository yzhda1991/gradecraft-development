module Services
  module Actions
    class RunsGradeUpdaterJob
      extend LightService::Action

      expects :grade

      executed do |context|
        grade = context[:grade]
        if grade.student_visible?
          grade_updater_job = GradeUpdaterJob.new(grade_id: grade.id)
          grade_updater_job.enqueue
        end
      end
    end
  end
end
