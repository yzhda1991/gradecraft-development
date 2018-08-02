require "light-service"
require_relative "updates_user/creates_course_membership"
require_relative "updates_user/updates_user"

module Services
  class UpdatesUserForCourse
    extend LightService::Organizer

    def self.call(user, attributes, course)
      with(user: user, attributes: attributes, course: course)
        .reduce(
          Actions::UpdatesUser,
          Actions::CreatesCourseMembership
        )
    end
  end
end
