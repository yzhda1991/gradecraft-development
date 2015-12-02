module Services
  module Actions
    class DestroysGroupMemberships
      extend LightService::Action

      expects :membership

      executed do |context|
        membership = context[:membership]

        GroupMembership.for_course(membership.course)
          .for_student(membership.user)
          .destroy_all
      end
    end
  end
end
