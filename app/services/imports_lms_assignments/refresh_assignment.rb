require "active_support"
require_relative "../../importers/assignment_importers"

module Services
  module Actions
    class RefreshAssignment
      extend LightService::Action
      extend ActiveSupport::Inflector

      expects :assignment, :lms_assignment, :provider

      executed do |context|
        assignment = context.assignment
        lms_assignment = context.lms_assignment
        provider = context.provider

        importer_class = constantize("#{camelize(provider)}AssignmentImporter")
        assignment = importer_class.import_row assignment, lms_assignment
        assignment.save
      end
    end
  end
end
