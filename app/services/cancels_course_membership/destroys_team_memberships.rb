module Services
  module Actions
    class DestroysTeamMemberships
      extend LightService::Action

      expects :membership

      executed do |context|
        membership = context[:membership]

        TeamMembership.for_course(membership.course)
          .for_student(membership.user)
          .destroy_all
      end
    end
  end
end
