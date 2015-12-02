module Services
  module Actions
    class DestroysAnnouncementStates
      extend LightService::Action

      expects :membership

      executed do |context|
        membership = context[:membership]

        AnnouncementState.for_course(membership.course)
          .for_user(membership.user)
          .destroy_all
      end
    end
  end
end
