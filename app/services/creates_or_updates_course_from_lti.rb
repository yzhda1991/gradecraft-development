require "light-service"
require_relative "creates_or_updates_user_from_lti/parse_course_attributes_from_auth_hash"
require_relative "creates_or_updates_user_from_lti/creates_or_updates_course_by_uid"

module Services
  class CreatesOrUpdatesCourseFromLTI
    extend LightService::Organizer

    def self.call(auth_hash, update_existing=true)
      with(auth_hash: auth_hash, update_existing: update_existing)
        .reduce(
          Actions::ParseCourseAttributesFromAuthHash,
          Actions::CreatesOrUpdatesCourseByUID
        )
    end
  end
end
