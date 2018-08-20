module Services
  module Actions
    class DestroysSubmissions
      extend LightService::Action

      expects :membership

      executed do |context|
        membership = context[:membership]

        Submission.for_course(membership.course)
          .for_student(membership.user.id)
          .destroy_all
      end
    end
  end
end
