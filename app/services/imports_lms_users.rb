require "light-service"
require_relative "imports_lms_users/imports_lms_users"
require_relative "imports_lms_users/retrieves_lms_users_with_roles"

module Services
  class ImportsLMSUsers
    extend LightService::Organizer

    def self.call(provider, access_token, course_id, user_ids, course)
      with(provider: provider, access_token: access_token,
        course_id: course_id, course: course, user_ids: user_ids).reduce(
          Actions::RetrievesLMSUsersWithRoles,
          Actions::ImportsLMSUsers
        )
    end
  end
end
