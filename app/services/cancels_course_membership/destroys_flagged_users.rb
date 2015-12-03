module Services
  module Actions
    class DestroysFlaggedUsers
      extend LightService::Action

      expects :membership

      executed do |context|
        membership = context[:membership]

        FlaggedUser.for_course(membership.course)
          .for_flagged(membership.user)
          .destroy_all
      end
    end
  end
end
