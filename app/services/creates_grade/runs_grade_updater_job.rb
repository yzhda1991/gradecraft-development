module Services
  module Actions
    class RunsGradeUpdaterJob
      extend LightService::Action

      expects :grade
      expects :update_grade

      executed do |context|
        grade = context[:grade]

        if GradeProctor.new(grade).viewable? && context[:update_grade]
          grade_updater_job = GradeUpdaterJob.new(grade_id: grade.id)
          grade_updater_job.enqueue
        end
      end
    end
  end
end
