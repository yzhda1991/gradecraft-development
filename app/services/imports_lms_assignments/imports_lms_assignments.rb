require_relative "../../importers/assignment_importers"

module Services
  module Actions
    class ImportsLMSAssignments
      extend LightService::Action

      expects :assignments, :assignment_type_id, :course
      promises :import_result

      executed do |context|
        assignments = context.assignments
        course = context.course
        assignment_type_id = context.assignment_type_id

        context.import_result = CanvasAssignmentImporter.new(assignments)
          .import course, assignment_type_id
      end
    end
  end
end
