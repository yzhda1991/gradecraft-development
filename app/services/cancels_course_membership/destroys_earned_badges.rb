module Services
  module Actions
    class DestroysEarnedBadges
      extend LightService::Action

      expects :membership

      executed do |context|
        membership = context[:membership]

        EarnedBadge.for_course(membership.course)
          .for_student(membership.user)
          .destroy_all

        PredictedEarnedBadge.for_course(membership.course)
          .for_student(membership.user)
          .destroy_all
      end
    end
  end
end
