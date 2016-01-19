module Services
  module Actions
    class SavesCriterionGrades
      extend LightService::Action

      expects :criterion_grades

      executed do |context|
        context[:criterion_grades].each do |cg|
          context.fail_with_rollback!("The criterion grade is invalid and cannot be saved", error_code: 422) \
            unless cg.save
        end
      end
    end
  end
end
