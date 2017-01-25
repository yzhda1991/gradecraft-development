require "light-service"
require_relative "creates_or_updates_user_from_lti/parse_user_attributes_from_auth_hash"
require_relative "creates_or_updates_user_from_lti/parse_course_attributes_from_auth_hash"
require_relative "creates_or_updates_user_from_lti/creates_or_updates_course_by_uid"
require_relative "creates_or_updates_user/creates_or_updates_user"

module Services
  class CreatesOrUpdatesModelsFromLTI
    extend LightService::Organizer

    aliases user_attributes: :attributes

    def self.create_or_update(auth_hash, send_welcome_email=false)
      with(auth_hash: auth_hash, send_welcome_email: send_welcome_email)
        .reduce(
          Actions::ParseUserAttributesFromAuthHash,
          Actions::ParseCourseAttributesFromAuthHash,
          Actions::CreatesOrUpdatesCourseByUID,
          Actions::CreatesOrUpdatesUser
        )
    end
  end
end
