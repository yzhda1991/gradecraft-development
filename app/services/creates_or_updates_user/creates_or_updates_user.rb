require_relative "../creates_new_user"

module Services
  module Actions
    class CreatesOrUpdatesUser
      extend LightService::Action

      expects :attributes, :course, :send_welcome_email

      executed do |context|
        attributes = context[:attributes]
        course = attributes[:course]

        Services::CreatesNewUser.create attributes
      end
    end
  end
end
