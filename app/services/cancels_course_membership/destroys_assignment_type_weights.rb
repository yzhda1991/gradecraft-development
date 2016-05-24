module Services
  module Actions
    class DestroysAssignmentTypeWeights
      extend LightService::Action

      expects :membership

      executed do |context|
        membership = context[:membership]

        AssignmentTypeWeight.for_course(membership.course)
          .for_student(membership.user)
          .destroy_all
      end
    end
  end
end
