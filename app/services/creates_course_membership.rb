require "light-service"
require_relative "updates_user/creates_course_membership"

module Services
  class CreatesCourseMembership
    extend LightService::Organizer

    def self.call(user, course)
      with(user: user, course: course)
        .reduce(
          Actions::CreatesCourseMembership
        )
    end
  end
end
