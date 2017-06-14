require "namae"

module Services
  module Actions
    class ParseUserAttributesFromAuthHash
      extend LightService::Action

      expects :auth_hash
      promises :user_attributes

      executed do |context|
        raise ArgumentError, "Unexpected auth_hash format" unless context.auth_hash.is_a? OmniAuth::AuthHash
        context.auth_hash.extra.raw_info.tap do |raw_info|
          ensure_valid_request context, raw_info
          email = raw_info.lis_person_contact_email_primary
          username = email.split("@")[0]
          names_hash = get_names(raw_info)

          context[:user_attributes] = {
            email: email,
            lti_uid: raw_info.lis_person_sourcedid,
            first_name: names_hash["first_name"],
            last_name: names_hash["last_name"],
            username: username,
            kerberos_uid: username
          }
        end
      end

      private

      # Fail context early if first_name, last_name are missing
      def self.ensure_valid_request(context, attributes)
        if attributes.lis_person_name_given.blank? && attributes.lis_person_name_family.blank? && attributes.lis_person_name_full.blank? &&
          attributes.lis_person_name_full.blank? && attributes.lis_person_contact_email_primary.present?
          context.fail! "Please check your LTI configuration", 400
        end
      end

      def self.get_names(raw_info)
        if !raw_info.lis_person_name_given.blank? && !raw_info.lis_person_name_family.blank?
          return names_hash = {"first_name" => raw_info.lis_person_name_given, "last_name" => raw_info.lis_person_name_family}
        elsif raw_info.lis_person_name_given.blank? && raw_info.lis_person_name_family.blank? && !raw_info.lis_person_name_full.blank?
          names = Namae.parse raw_info.lis_person_name_full
          names[0].family = names[0].given if names[0].family == nil # If user has only one name, will set that name as first name and last name
          return names_hash = {"first_name" => names[0].given, "last_name" => names[0].family}
        end
      end

    end
  end
end
