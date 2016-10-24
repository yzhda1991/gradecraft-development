module Services
  module Actions
    class RunsGradeUpdaterJob
      extend LightService::Action
      
      expects :grade, :update_grade, :student_visible_status

      executed do |context|
        grade = context[:grade]

        if context[:student_visible_status] == true && context[:update_grade]
          grade_updater_job = GradeUpdaterJob.new(grade_id: grade.id)
          grade_updater_job.enqueue
        end
      end
    end
  end
end
