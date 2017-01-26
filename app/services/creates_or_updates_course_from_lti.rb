require "light-service"
require_relative "creates_or_updates_user_from_lti/parse_course_attributes_from_auth_hash"
require_relative "creates_or_updates_user_from_lti/creates_or_updates_course_by_uid"

module Services
  class CreatesOrUpdatesCourseFromLTI
    extend LightService::Organizer

    def self.create_or_update(auth_hash)
      with(auth_hash: auth_hash)
        .reduce(
          Actions::ParseCourseAttributesFromAuthHash,
          Actions::CreatesOrUpdatesCourseByUID
        )
    end
  end
end
