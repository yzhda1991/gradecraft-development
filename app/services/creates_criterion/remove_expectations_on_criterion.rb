module Services
  module Actions
    class RemoveExpectationsOnCriterion
      extend LightService::Action

      expects :criterion

      executed do |context|
        criterion = context[:criterion]
        criterion.meets_expectations_level_id = nil
        criterion.meets_expectations_points = 0
        context.fail_with_rollback!("The criterion is invalid and cannot be saved", error_code: 422) \
          unless criterion.save
      end
    end
  end
end
