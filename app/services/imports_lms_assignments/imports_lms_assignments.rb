require_relative "../../importers/assignment_importers"

module Services
  module Actions
    class ImportsLMSAssignments
      extend LightService::Action
      extend ActiveSupport::Inflector

      expects :assignments, :assignment_type_id, :course, :provider
      promises :import_result

      executed do |context|
        assignments = context.assignments
        course = context.course
        assignment_type_id = context.assignment_type_id
        provider = context.provider

        klass = constantize("#{camelize(provider)}AssignmentImporter")
        context.import_result = klass.new(assignments)
          .import course, assignment_type_id
      end
    end
  end
end
