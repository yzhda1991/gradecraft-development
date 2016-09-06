require "light-service"
require_relative "imports_lms_assignments/imports_lms_assignments"
require_relative "imports_lms_assignments/refresh_assignment"
require_relative "imports_lms_assignments/retrieves_imported_assignment"
require_relative "imports_lms_assignments/retrieves_lms_assignment"
require_relative "imports_lms_assignments/retrieves_lms_assignments"

module Services
  class ImportsLMSAssignments
    extend LightService::Organizer

    def self.import(provider, access_token, course_id, assignment_ids, course,
                    assignment_type_id)
      with(provider: provider, access_token: access_token, course_id: course_id,
           assignment_ids: assignment_ids, course: course,
           assignment_type_id: assignment_type_id).reduce(
             Actions::RetrievesLMSAssignments,
             Actions::ImportsLMSAssignments
      )
    end

    def self.refresh(provider, access_token, assignment)
      with(provider: provider, access_token: access_token, assignment: assignment).reduce(
        Actions::RetrievesImportedAssignment,
        Actions::RetrievesLMSAssignment,
        Actions::RefreshAssignment
      )
    end
  end
end
