require_relative "../../proctors/earned_badge_proctor"

module Services
  module Actions
    class CreatesEarnedBadge
      extend LightService::Action

      expects :attributes
      promises :earned_badge

      executed do |context|
        context.earned_badge = EarnedBadge.new context.attributes

        unless EarnedBadgeProctor.new(context.earned_badge).creatable? context.earned_badge.awarded_by
          message = "Permission denied"
          context.fail_with_rollback! message
        end

        unless context.earned_badge.save
          message = "The earned badge is invalid and cannot be saved"
          context.fail_with_rollback! message
        end
      end
    end
  end
end
