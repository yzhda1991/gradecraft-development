module Services
  module Actions
    class SavesEarnedLevelBadges
      extend LightService::Action

      expects :earned_level_badges

      executed do |context|
        context[:earned_level_badges].each do |elb|
          context.fail_with_rollback!("The earned badge is invalid and cannot be saved", error_code: 422) \
            unless elb.save
        end
      end
    end
  end
end

