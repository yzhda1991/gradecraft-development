require "light-service"
require_relative "imports_lms_assignments/imports_lms_assignments"
require_relative "imports_lms_assignments/refresh_assignment"
require_relative "imports_lms_assignments/retrieves_imported_assignment"
require_relative "imports_lms_assignments/retrieves_lms_assignment"
require_relative "imports_lms_assignments/retrieves_lms_assignments"
require_relative "imports_lms_assignments/updates_imported_timestamp"
require_relative "imports_lms_assignments/updates_lms_assignment"

module Services
  module ImportsLMSAssignments
    class Import
      extend LightService::Organizer

      def self.call(provider, access_token, course_id, assignment_ids, course,
                    assignment_type_id)
        with(provider: provider, access_token: access_token, course_id: course_id,
             assignment_ids: assignment_ids, course: course,
             assignment_type_id: assignment_type_id).reduce(
               Actions::RetrievesLMSAssignments,
               Actions::ImportsLMSAssignments
        )
      end
    end
  end
end

module Services
  module ImportsLMSAssignments
    class Refresh
      extend LightService::Organizer

      def self.call(provider, access_token, assignment)
        with(provider: provider, access_token: access_token, assignment: assignment).reduce(
          Actions::RetrievesImportedAssignment,
          Actions::RetrievesLMSAssignment,
          Actions::RefreshAssignment,
          Actions::UpdatesImportedTimestamp
        )
      end
    end
  end
end

module Services
  module ImportsLMSAssignments
    class Update
      extend LightService::Organizer
      
      def self.call(provider, access_token, assignment)
        with(provider: provider, access_token: access_token, assignment: assignment).reduce(
          Actions::RetrievesImportedAssignment,
          Actions::UpdatesLMSAssignment
        )
      end
    end
  end
end
