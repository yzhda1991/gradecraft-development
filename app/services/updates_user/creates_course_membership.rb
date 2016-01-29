module Services
  module Actions
    class CreatesCourseMembership
      extend LightService::Action

      expects :course, :user

      executed do |context|
        course = context[:course]
        user = context[:user]

        unless user.course_memberships.map(&:course_id).include? course.id
          user.course_memberships.create(course_id: course.id, role: :student)
        end
      end
    end
  end
end
