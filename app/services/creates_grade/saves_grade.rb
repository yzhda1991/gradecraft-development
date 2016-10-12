module Services
  module Actions
    class SavesGrade
      extend LightService::Action

      expects :grade
      promises :update_grade

      executed do |context|
        grade = context[:grade]
        context.fail_with_rollback!("The grade is invalid and cannot be saved", error_code: 422) \
          unless grade.save
        context[:update_grade] = grade.previous_changes[:raw_points].present? && grade.graded_or_released?
        # warning: LightService doesn't set context keys to false, will be nil !
      end
    end
  end
end
