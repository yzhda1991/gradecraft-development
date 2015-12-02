module Services
  module Actions
    class DestroysGrades
      extend LightService::Action

      expects :membership

      executed do |context|
        membership = context[:membership]

        Grade.for_course(membership.course)
          .for_student(membership.user)
          .destroy_all

        RubricGrade.for_course(membership.course)
          .for_student(membership.user)
          .destroy_all
      end
    end
  end
end
