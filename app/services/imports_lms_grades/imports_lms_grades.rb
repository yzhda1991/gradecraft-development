require "active_lms"
require_relative "../../importers/grade_importers"

module Services
  module Actions
    class ImportsLMSGrades
      extend LightService::Action
      extend ActiveSupport::Inflector

      expects :assignment_id, :grades, :provider, :user
      promises :import_result

      executed do |context|
        assignment_id = context.assignment_id
        grades = context.grades
        provider = context.provider
        user = context.user
        authorization = UserAuthorization.for(user, provider)

        context.import_result = nil
        unless authorization.nil?
          klass = constantize("#{camelize(provider)}GradeImporter")
          syllabus = ActiveLMS::Syllabus.new provider,
            authorization.access_token
          context.import_result = klass.new(grades).import assignment_id, syllabus
        end
      end
    end
  end
end
