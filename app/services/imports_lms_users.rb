require "light-service"
require_relative "imports_lms_users/imports_lms_users"
require_relative "imports_lms_users/retrieves_lms_users"

module Services
  class ImportsLMSUsers
    extend LightService::Organizer

    def self.import(provider, access_token, course_id, course)
      with(provider: provider, access_token: access_token,
        course_id: course_id, course: course).reduce(
          Actions::RetrievesLMSUsersWithRoles,
          Actions::ImportsLMSUsers
      )
    end
  end
end
