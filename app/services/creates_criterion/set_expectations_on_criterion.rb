module Services
  module Actions
    class SetExpectationsOnCriterion
      extend LightService::Action

      expects :criterion
      expects :level

      executed do |context|
        criterion = context[:criterion]
        criterion.meets_expectations_level_id = context[:level].id
        criterion.meets_expectations_points = context[:level].points
        context.fail_with_rollback!("The criterion is invalid and cannot be saved", error_code: 422) \
          unless criterion.save
      end
    end
  end
end
