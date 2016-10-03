require_relative "../../importers/student_importers"

module Services
  module Actions
    class ImportsLMSUsers
      extend LightService::Action
      extend ActiveSupport::Inflector

      expects :course, :provider, :users
      promises :import_result

      executed do |context|
        course = context.course
        users = context.users
        provider = context.provider

        klass = constantize("#{camelize(provider)}StudentImporter")
        context.import_result = klass.new(users).import course
      end
    end
  end
end
