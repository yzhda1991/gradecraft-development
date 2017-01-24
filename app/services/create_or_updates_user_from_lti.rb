require "light-service"
require_relative "creates_or_updates_user_from_lti/parse_user_attributes_from_auth_hash"
require_relative "creates_or_updates_user/creates_or_updates_user"
require_relative "updates_user/creates_course_membership"

module Services
  class CreatesOrUpdatesUserFromLTI
    extend LightService::Organizer

    def self.create_or_update(auth_hash)
      with(auth_hash: auth_hash)
        .reduce(
          Actions::ParseUserAttributesFromAuthHash
          Actions::CreatesOrUpdatesUser
          Actions::CreatesCourseMembership
        )
    end
  end
end
