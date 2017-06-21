module Services
  module Actions
    class SavesGrade
      extend LightService::Action

      expects :grade

      executed do |context|
        grade = context[:grade]
        context.fail_with_rollback!("The grade is invalid and cannot be saved", error_code: 422) \
          unless grade.save
      end
    end
  end
end
