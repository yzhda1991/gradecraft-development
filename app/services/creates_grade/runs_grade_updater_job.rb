module Services
  module Actions
    class RunsGradeUpdaterJob
      extend LightService::Action

      expects :grade
      expects :student_visible_status

      executed do |context|
        grade = context[:grade]
        if grade.is_student_visible?
          grade_updater_job = GradeUpdaterJob.new(grade_id: grade.id)
          grade_updater_job.enqueue
        end
      end
    end
  end
end
