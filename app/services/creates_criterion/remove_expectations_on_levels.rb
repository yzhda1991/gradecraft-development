module Services
  module Actions
    class RemoveExpectationsOnLevels
      extend LightService::Action

      expects :criterion

      executed do |context|
        context[:criterion].levels.each do |level|
          if level.meets_expectations
            level.update(meets_expectations: false)
          end
        end
      end
    end
  end
end

