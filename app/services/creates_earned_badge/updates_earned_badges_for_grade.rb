require_relative "../../proctors/earned_badge_proctor"

module Services
  module Actions
    class UpdatesEarnedBadgesForGrade
      extend LightService::Action

      expects :grade

      executed do |context|
        EarnedBadge.where(grade_id: context[:grade].id).each(&:save)
      end
    end
  end
end
