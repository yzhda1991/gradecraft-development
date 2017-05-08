module Services
  module Actions
    class SetExpectationsOnLevels
      extend LightService::Action

      expects :criterion
      expects :level

      executed do |context|
        context[:criterion].levels do |level|
          if level == context[:level]
            level.update(meets_expectations: true)
          else
            level.update(meets_expectations: false)
          end
        end
      end
    end
  end
end
