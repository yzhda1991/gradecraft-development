module Services
  module Actions
    class ParseCourseAttributesFromAuthHash
      extend LightService::Action

      expects :auth_hash
      promises :course_attributes

      executed do |context|
        raise ArgumentError, "Unexpected auth_hash format" unless context.auth_hash.is_a? OmniAuth::AuthHash
        context.auth_hash.extra.raw_info.tap do |raw_info|
          context[:course_attributes] = {
            lti_uid: raw_info.context_id,
            course_number: raw_info.context_label,
            name: raw_info.context_title
          }
        end
      end
    end
  end
end
