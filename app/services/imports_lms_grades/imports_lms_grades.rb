require "active_lms"
require_relative "../../importers/grade_importers"

module Services
  module Actions
    class ImportsLMSGrades
      extend LightService::Action
      extend ActiveSupport::Inflector

      expects :assignment, :grades, :provider, :user
      promises :import_result

      executed do |context|
        assignment = context.assignment
        grades = context.grades
        provider = context.provider
        user = context.user
        authorization = UserAuthorization.for(user, provider)

        context.import_result = nil
        unless authorization.nil?
          klass = constantize("#{camelize(provider)}GradeImporter")
          syllabus = ActiveLMS::Syllabus.new provider,
            authorization.access_token
          context.import_result = klass.new(grades).import assignment.id, syllabus
        end
      end
    end
  end
end
