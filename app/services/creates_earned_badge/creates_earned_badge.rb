require_relative "../../proctors/earned_badge_proctor"

module Services
  module Actions
    class CreatesEarnedBadge
      extend LightService::Action

      expects :attributes
      promises :earned_badge

      executed do |context|
        context.earned_badge = EarnedBadge.new context.attributes
        if context.earned_badge.awarded_by.present? && !EarnedBadgeProctor.new(context.earned_badge).creatable?(context.earned_badge.awarded_by)
          context.fail_with_rollback! "Permission denied"
        end
        unless context.earned_badge.save
          context.fail_with_rollback! "The earned badge is invalid and cannot be saved"
        end
      end
    end
  end
end
