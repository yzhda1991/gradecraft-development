# Defines if the true result of a chained set of service calls
# is successful or not; expects an array of unsuccessful results
module Services
  module Actions
    class AssertResultFromManyOutcomes
      extend LightService::Action

      expects :unsuccessful

      executed do |context|
        unsuccessful = context[:unsuccessful]
        context.fail!("Failed to update #{unsuccessful.length} #{"grade".pluralize(unsuccessful.length)}") \
          unless unsuccessful.empty?
      end
    end
  end
end
